#!/usr/bin/swift

//
//  syncstrings.swift
//
//  Copyright © 2026 Rivia Corp s.r.o.
//

import Darwin
import Foundation

// MARK: - StringsSync

struct StringsSync {
    let baseLocale: String = "en"
    let fileManager: FileManager = .default
    let placeholderValue: String = "TODO"

    enum SyncError: Error, CustomStringConvertible {
        case duplicateKey(path: String, key: String, line: Int)
        case invalidRoot(String)
        case noBaseLocale(root: String, locale: String)
        case noBaseStrings(localeDirectory: String)
        case parse(path: String, line: Int, message: String)
        case read(path: String, error: Error)
        case usage
        case write(path: String, error: Error)

        var description: String {
            switch self {
                case let .duplicateKey(path, key, line):
                    "\(path):\(line): duplicate key \"\(key)\""

                case let .invalidRoot(path):
                    "Root path does not exist or is not a directory: \(path)"

                case let .noBaseLocale(root, locale):
                    "No \(locale).lproj directory found under \(root)"

                case let .noBaseStrings(localeDirectory):
                    "No .strings files found in baseline locale directory: \(localeDirectory)"

                case let .parse(path, line, message):
                    "\(path):\(line): \(message)"

                case let .read(path, error):
                    "Could not read \(path): \(error.localizedDescription)"

                case .usage:
                    "Usage: syncstrings.swift [root-path] [base-locale]"

                case let .write(path, error):
                    "Could not write \(path): \(error.localizedDescription)"
            }
        }
    }

    struct Entry {
        let key: String
        let leadingTrivia: String
        let rawKey: String
        let rawValue: String
    }

    struct StringsFile {
        let entries: [Entry]
        let trailingTrivia: String
    }

    struct Summary {
        var addedKeys: Int = 0
        var baseFiles: Int = 0
        var changedTargets: Int = 0
        var createdTargets: Int = 0
        var removedKeys: Int = 0
        var targetFiles: Int = 0
    }

    func perform(arguments: [String]) throws {
        if arguments.contains("--help") || arguments.contains("-h") {
            print(Self.usage)
            return
        }

        guard arguments.count <= 2 else {
            throw SyncError.usage
        }

        let rootPath: String = arguments.first ?? self.fileManager.currentDirectoryPath
        let selectedBaseLocale: String = arguments.count == 2 ? arguments[1] : self.baseLocale
        let expandedRootPath: String = if rootPath == "~" {
            self.fileManager.homeDirectoryForCurrentUser.path
        } else if rootPath.hasPrefix("~/") {
            self.fileManager
                .homeDirectoryForCurrentUser
                .appendingPathComponent(String(rootPath.dropFirst(2)))
                .path
        } else {
            rootPath
        }
        let rootURL: URL = .init(fileURLWithPath: expandedRootPath, isDirectory: true).standardizedFileURL

        guard (try? rootURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
            throw SyncError.invalidRoot(rootURL.path)
        }

        var summary: Summary = .init()
        let baseDirectories: [URL] = try baseLocaleDirectories(rootURL: rootURL, baseLocale: selectedBaseLocale)
        guard !baseDirectories.isEmpty else {
            throw SyncError.noBaseLocale(root: rootURL.path, locale: selectedBaseLocale)
        }

        for baseDirectory in baseDirectories {
            let stringsFiles: [URL] = try stringsFiles(in: baseDirectory)
            if stringsFiles.isEmpty {
                continue
            }

            let targetLocaleDirectories: [URL] = try siblingLocaleDirectories(
                for: baseDirectory,
                baseLocale: selectedBaseLocale,
            )
            for baseStringsFile in stringsFiles {
                summary.baseFiles += 1
                let baseFile: StringsFile = try parseStringsFile(baseStringsFile)
                for targetLocaleDirectory in targetLocaleDirectories {
                    try self.sync(
                        baseFile: baseFile,
                        baseURL: baseStringsFile,
                        targetLocaleDirectory: targetLocaleDirectory,
                        rootURL: rootURL,
                        summary: &summary,
                    )
                }
            }
        }

        guard summary.baseFiles > 0 else {
            throw SyncError.noBaseStrings(localeDirectory: "\(selectedBaseLocale).lproj under \(rootURL.path)")
        }

        print(
            "Checked \(summary.baseFiles) baseline file(s) and \(summary.targetFiles) target file(s). " +
                "Updated \(summary.changedTargets) file(s), created \(summary.createdTargets) file(s), " +
                "added \(summary.addedKeys) key(s), removed \(summary.removedKeys) key(s).",
        )
    }

    static let usage: String = [
        "Usage: syncstrings.swift [root-path] [base-locale]",
        "",
        "Defaults:",
        "  root-path: current directory",
        "  base-locale: en",
        "",
        "The script finds <base-locale>.lproj/*.strings files and syncs sibling *.lproj files.",
        "Existing translations are preserved, missing keys are written as \"TODO\", and keys missing from the baseline are removed.",
    ].joined(separator: "\n")

    func baseLocaleDirectories(rootURL: URL, baseLocale: String) throws -> [URL] {
        var directories: [URL] = []
        if rootURL.pathExtension == "lproj", rootURL.deletingPathExtension().lastPathComponent == baseLocale {
            directories.append(rootURL)
        }

        guard
            let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(
                at: rootURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles],
            ) else
        {
            return directories
        }

        for case let url as URL in enumerator where url.pathExtension == "lproj" {
            enumerator.skipDescendants()
            guard url.deletingPathExtension().lastPathComponent == baseLocale else {
                continue
            }

            let values: URLResourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true {
                directories.append(url)
            }
        }

        return directories.sorted { $0.path < $1.path }
    }

    func displayPath(_ url: URL, rootURL: URL) -> String {
        let normalizedURL: URL = url.standardizedFileURL
        let normalizedRootURL: URL = rootURL.standardizedFileURL
        let rootPath: String = normalizedRootURL.path.hasSuffix("/") ? normalizedRootURL.path : normalizedRootURL
            .path + "/"
        if normalizedURL.path.hasPrefix(rootPath) {
            return String(normalizedURL.path.dropFirst(rootPath.count))
        }
        return normalizedURL.path
    }

    func lineNumber(in contents: String, at index: String.Index) -> Int {
        var line: Int = 1
        var cursor: String.Index = contents.startIndex
        while cursor < index {
            if contents[cursor] == "\n" {
                line += 1
            }
            cursor = contents.index(after: cursor)
        }
        return line
    }

    func parseStringLiteral(in contents: String, at startIndex: String.Index, path: String) throws
        -> (decoded: String, raw: String, endIndex: String.Index)
    {
        guard startIndex < contents.endIndex, contents[startIndex] == "\"" else {
            throw SyncError.parse(
                path: path,
                line: self.lineNumber(in: contents, at: startIndex),
                message: "Expected string literal",
            )
        }

        let rawStart: String.Index = contents.index(after: startIndex)
        var decoded: String = ""
        var cursor: String.Index = rawStart

        func readUnicodeEscapeValue(from escapeStart: String.Index) throws -> (value: UInt32, endIndex: String.Index) {
            var scalarValue: UInt32 = 0
            var digitCursor: String.Index = contents.index(after: escapeStart)
            for _ in 0 ..< 4 {
                guard
                    digitCursor < contents.endIndex,
                    let hexValue: UInt32 = hexDigitValue(contents[digitCursor]) else
                {
                    throw SyncError.parse(
                        path: path,
                        line: self.lineNumber(in: contents, at: escapeStart),
                        message: "Expected four hexadecimal digits after unicode escape",
                    )
                }

                scalarValue = scalarValue * 16 + hexValue
                digitCursor = contents.index(after: digitCursor)
            }
            return (scalarValue, digitCursor)
        }

        while cursor < contents.endIndex {
            let character: Character = contents[cursor]
            if character == "\"" {
                let raw: String = .init(contents[rawStart ..< cursor])
                return (decoded, raw, contents.index(after: cursor))
            }

            if character == "\\" {
                cursor = contents.index(after: cursor)
                guard cursor < contents.endIndex else {
                    throw SyncError.parse(
                        path: path,
                        line: self.lineNumber(in: contents, at: cursor),
                        message: "Unterminated escape sequence",
                    )
                }

                switch contents[cursor] {
                    case "\"":
                        decoded.append("\"")
                        cursor = contents.index(after: cursor)

                    case "'":
                        decoded.append("'")
                        cursor = contents.index(after: cursor)

                    case "\\":
                        decoded.append("\\")
                        cursor = contents.index(after: cursor)

                    case "/":
                        decoded.append("/")
                        cursor = contents.index(after: cursor)

                    case "0":
                        decoded.append("\0")
                        cursor = contents.index(after: cursor)

                    case "a":
                        decoded.append("\u{7}")
                        cursor = contents.index(after: cursor)

                    case "b":
                        decoded.append("\u{8}")
                        cursor = contents.index(after: cursor)

                    case "f":
                        decoded.append("\u{C}")
                        cursor = contents.index(after: cursor)

                    case "n":
                        decoded.append("\n")
                        cursor = contents.index(after: cursor)

                    case "r":
                        decoded.append("\r")
                        cursor = contents.index(after: cursor)

                    case "t":
                        decoded.append("\t")
                        cursor = contents.index(after: cursor)

                    case "u", "U":
                        let unicodeStart: String.Index = cursor
                        let escapedScalar: (value: UInt32, endIndex: String.Index) = try readUnicodeEscapeValue(
                            from: unicodeStart,
                        )
                        let scalarValue: UInt32 = escapedScalar.value
                        cursor = escapedScalar.endIndex

                        if (0xD800 ... 0xDBFF).contains(scalarValue) {
                            guard cursor < contents.endIndex, contents[cursor] == "\\" else {
                                throw SyncError.parse(
                                    path: path,
                                    line: self.lineNumber(in: contents, at: unicodeStart),
                                    message: "Expected low-surrogate unicode escape after high surrogate",
                                )
                            }

                            let lowSurrogateStart: String.Index = contents.index(after: cursor)
                            guard
                                lowSurrogateStart < contents.endIndex,
                                contents[lowSurrogateStart] == "u" || contents[lowSurrogateStart] == "U" else
                            {
                                throw SyncError.parse(
                                    path: path,
                                    line: self.lineNumber(in: contents, at: unicodeStart),
                                    message: "Expected low-surrogate unicode escape after high surrogate",
                                )
                            }

                            let escapedLowSurrogate: (
                                value: UInt32,
                                endIndex: String.Index,
                            ) = try readUnicodeEscapeValue(
                                from: lowSurrogateStart,
                            )
                            guard (0xDC00 ... 0xDFFF).contains(escapedLowSurrogate.value) else {
                                throw SyncError.parse(
                                    path: path,
                                    line: self.lineNumber(in: contents, at: lowSurrogateStart),
                                    message: "Invalid low surrogate in unicode escape pair",
                                )
                            }

                            let combinedScalarValue: UInt32 = 0x10000 + ((scalarValue - 0xD800) << 10) +
                                (escapedLowSurrogate.value - 0xDC00)
                            guard let scalar: UnicodeScalar = .init(combinedScalarValue) else {
                                throw SyncError.parse(
                                    path: path,
                                    line: self.lineNumber(in: contents, at: unicodeStart),
                                    message: "Invalid unicode scalar in string literal",
                                )
                            }

                            // Escaped non-BMP characters are stored as UTF-16 surrogate pairs in many .strings files.
                            decoded.unicodeScalars.append(scalar)
                            cursor = escapedLowSurrogate.endIndex
                            continue
                        }

                        if (0xDC00 ... 0xDFFF).contains(scalarValue) {
                            throw SyncError.parse(
                                path: path,
                                line: self.lineNumber(in: contents, at: unicodeStart),
                                message: "Unpaired low surrogate in unicode escape",
                            )
                        }

                        guard let scalar: UnicodeScalar = .init(scalarValue) else {
                            throw SyncError.parse(
                                path: path,
                                line: self.lineNumber(in: contents, at: unicodeStart),
                                message: "Invalid unicode scalar in string literal",
                            )
                        }

                        decoded.unicodeScalars.append(scalar)

                    default:
                        throw SyncError.parse(
                            path: path,
                            line: self.lineNumber(in: contents, at: cursor),
                            message: "Unsupported escape sequence \\\(contents[cursor])",
                        )
                }

                continue
            }

            decoded.append(character)
            cursor = contents.index(after: cursor)
        }

        throw SyncError.parse(
            path: path,
            line: self.lineNumber(in: contents, at: startIndex),
            message: "Unterminated string literal",
        )
    }

    func readContents(of url: URL) throws -> String {
        var encoding: String.Encoding = .utf8
        do {
            return try String(contentsOf: url, usedEncoding: &encoding)
        } catch {
            throw SyncError.read(path: url.path, error: error)
        }
    }

    func parseStringsFile(_ url: URL) throws -> StringsFile {
        let contents: String = try self.readContents(of: url)

        var entries: [Entry] = []
        var seenKeys: [String: Int] = [:]
        var cursor: String.Index = contents.startIndex
        var triviaStart: String.Index = cursor

        while cursor < contents.endIndex {
            try self.skipTrivia(in: contents, cursor: &cursor, path: url.path)
            if cursor == contents.endIndex {
                break
            }

            let leadingTrivia: String = .init(contents[triviaStart ..< cursor])
            let line: Int = self.lineNumber(in: contents, at: cursor)
            let keyLiteral: (decoded: String, raw: String, endIndex: String.Index) = try self.parseStringLiteral(
                in: contents,
                at: cursor,
                path: url.path,
            )
            cursor = keyLiteral.endIndex
            try self.skipTrivia(in: contents, cursor: &cursor, path: url.path)

            guard cursor < contents.endIndex, contents[cursor] == "=" else {
                throw SyncError.parse(
                    path: url.path,
                    line: self.lineNumber(in: contents, at: cursor),
                    message: "Expected =",
                )
            }

            cursor = contents.index(after: cursor)
            try self.skipTrivia(in: contents, cursor: &cursor, path: url.path)

            let valueLiteral: (decoded: String, raw: String, endIndex: String.Index) = try self.parseStringLiteral(
                in: contents,
                at: cursor,
                path: url.path,
            )
            cursor = valueLiteral.endIndex
            try self.skipTrivia(in: contents, cursor: &cursor, path: url.path)

            guard cursor < contents.endIndex, contents[cursor] == ";" else {
                throw SyncError.parse(
                    path: url.path,
                    line: self.lineNumber(in: contents, at: cursor),
                    message: "Expected ;",
                )
            }

            cursor = contents.index(after: cursor)

            if seenKeys[keyLiteral.decoded] != nil {
                throw SyncError.duplicateKey(path: url.path, key: keyLiteral.decoded, line: line)
            }
            seenKeys[keyLiteral.decoded] = line

            entries.append(
                Entry(
                    key: keyLiteral.decoded,
                    leadingTrivia: leadingTrivia,
                    rawKey: keyLiteral.raw,
                    rawValue: valueLiteral.raw,
                ),
            )
            triviaStart = cursor
        }

        return StringsFile(entries: entries, trailingTrivia: String(contents[triviaStart ..< contents.endIndex]))
    }

    func renderedTargetContent(baseFile: StringsFile, targetValues: [String: String]) -> String {
        var rendered: String = ""
        for entry in baseFile.entries {
            // Baseline trivia carries generated comments/order so each locale stays aligned with the English file.
            rendered += entry.leadingTrivia
            rendered += "\"\(entry.rawKey)\" = \"\(targetValues[entry.key] ?? self.placeholderValue)\";"
        }
        rendered += baseFile.trailingTrivia

        if !rendered.isEmpty, !rendered.hasSuffix("\n") {
            rendered += "\n"
        }
        return rendered
    }

    func siblingLocaleDirectories(for baseDirectory: URL, baseLocale: String) throws -> [URL] {
        let parentDirectory: URL = baseDirectory.deletingLastPathComponent()
        let directoryContents: [URL] = try fileManager.contentsOfDirectory(
            at: parentDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles],
        )

        return try directoryContents.compactMap { url -> URL? in
            guard url.pathExtension == "lproj", url.deletingPathExtension().lastPathComponent != baseLocale else {
                return nil
            }

            let values: URLResourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            return values.isDirectory == true ? url : nil
        }
        .sorted { $0.path < $1.path }
    }

    func skipTrivia(in contents: String, cursor: inout String.Index, path: String) throws {
        while cursor < contents.endIndex {
            if contents[cursor].isWhitespace {
                cursor = contents.index(after: cursor)
                continue
            }

            guard contents[cursor] == "/" else {
                return
            }

            let slashIndex: String.Index = cursor
            cursor = contents.index(after: cursor)
            guard cursor < contents.endIndex else {
                cursor = slashIndex
                return
            }

            if contents[cursor] == "/" {
                cursor = contents.index(after: cursor)
                while cursor < contents.endIndex, contents[cursor] != "\n" {
                    cursor = contents.index(after: cursor)
                }
                continue
            }

            if contents[cursor] == "*" {
                cursor = contents.index(after: cursor)
                var foundCommentEnd: Bool = false
                while cursor < contents.endIndex {
                    if contents[cursor] == "*" {
                        let nextIndex: String.Index = contents.index(after: cursor)
                        if nextIndex < contents.endIndex, contents[nextIndex] == "/" {
                            cursor = contents.index(after: nextIndex)
                            foundCommentEnd = true
                            break
                        }
                    }
                    cursor = contents.index(after: cursor)
                }

                guard foundCommentEnd else {
                    throw SyncError.parse(
                        path: path,
                        line: self.lineNumber(in: contents, at: slashIndex),
                        message: "Unterminated block comment",
                    )
                }

                continue
            }

            cursor = slashIndex
            return
        }
    }

    func stringsFiles(in localeDirectory: URL) throws -> [URL] {
        let directoryContents: [URL] = try fileManager.contentsOfDirectory(
            at: localeDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles],
        )

        return try directoryContents.compactMap { url -> URL? in
            guard url.pathExtension == "strings" else {
                return nil
            }

            let values: URLResourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            return values.isDirectory == true ? nil : url
        }
        .sorted { $0.path < $1.path }
    }

    func sync(
        baseFile: StringsFile,
        baseURL: URL,
        targetLocaleDirectory: URL,
        rootURL: URL,
        summary: inout Summary,
    )
        throws
    {
        let targetURL: URL = targetLocaleDirectory.appendingPathComponent(baseURL.lastPathComponent)
        let targetExists: Bool = self.fileManager.fileExists(atPath: targetURL.path)
        let targetFile: StringsFile = targetExists ? try parseStringsFile(targetURL) : StringsFile(
            entries: [],
            trailingTrivia: "",
        )
        var targetValues: [String: String] = [:]
        for entry in targetFile.entries {
            targetValues[entry.key] = entry.rawValue
        }
        let baseKeys: Set<String> = Set(baseFile.entries.map(\.key))
        let targetKeys: Set<String> = Set(targetFile.entries.map(\.key))
        let addedKeys: Int = baseKeys.subtracting(targetKeys).count
        let removedKeys: Int = targetKeys.subtracting(baseKeys).count
        let renderedContent: String = self.renderedTargetContent(baseFile: baseFile, targetValues: targetValues)
        let existingContent: String? = if targetExists {
            try self.readContents(of: targetURL)
        } else {
            nil
        }

        summary.targetFiles += 1
        if existingContent != renderedContent {
            do {
                try renderedContent.write(to: targetURL, atomically: true, encoding: .utf8)
            } catch {
                throw SyncError.write(path: targetURL.path, error: error)
            }

            summary.changedTargets += 1
            if !targetExists {
                summary.createdTargets += 1
            }
            summary.addedKeys += addedKeys
            summary.removedKeys += removedKeys
            print("Synced \(self.displayPath(targetURL, rootURL: rootURL)) (+\(addedKeys), -\(removedKeys))")
        }
    }

    func hexDigitValue(_ character: Character) -> UInt32? {
        guard character.unicodeScalars.count == 1, let value: UInt32 = character.unicodeScalars.first?.value else {
            return nil
        }

        switch value {
            case 48 ... 57:
                return value - 48

            case 65 ... 70:
                return value - 55

            case 97 ... 102:
                return value - 87

            default:
                return nil
        }
    }
}

let sync: StringsSync = .init()

do {
    try sync.perform(arguments: Array(CommandLine.arguments.dropFirst()))
} catch let error as StringsSync.SyncError {
    FileHandle.standardError.write(Data("error: \(error.description)\n".utf8))
    Darwin.exit(1)
} catch {
    FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
    Darwin.exit(1)
}
