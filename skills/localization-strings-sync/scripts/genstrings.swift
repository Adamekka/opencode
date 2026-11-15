#!/usr/bin/swift

//
//  genstrings.swift
//
//  Copyright © 2026 Rivia Corp s.r.o.
//

// swiftlint:disable legacy_objc_type

import Foundation

// MARK: - GenStrings

struct GenStrings {
    let str: String = "Hello, playground"
    let fileManager: FileManager = .default
    let acceptedFileExtensions: [String] = ["swift"]
    let excludedFolderNames: [String] = ["Carthage"]
    let excludedFileNames: [String] = ["genstrings.swift"]
    var regularExpresions: [String: NSRegularExpression] = [:]

    let localizedRegex: String = "(?<=\")([^\"]*)(?=\".(localized|localizedFormat))|(?<=(Localized|NSLocalizedString)\\(\")([^\"]*?)(?=\")"
    let commentedRegex: String = "(?<=.commented\\(\")([^\"]*)(?=\")"

    enum GenstringsError: Error {
        case Error
    }

    // Performs the genstrings functionality
    mutating func perform(path: String?) {
        let directoryPath: String = path ?? self.fileManager.currentDirectoryPath
        let rootPath: URL = .init(fileURLWithPath: directoryPath)
        let allFiles: [URL] = self.fetchFilesInFolder(rootPath: rootPath)
        // We use a set to avoid duplicates
        var localizableStrings: Set<String> = []
        var comments: [String: String] = [:]
        for filePath: URL in allFiles {
            let (stringsInFile, commentsInFile): (Set<String>, [String: String]) =
                self.localizableStringsInFile(filePath: filePath)
            localizableStrings = localizableStrings.union(stringsInFile)
            comments = comments.merging(commentsInFile) { _, last in last }
        }
        // We sort the strings
        let sortedStrings: [String] = localizableStrings.sorted { $0 < $1 }
        var processedStrings: String = ""
        for string in sortedStrings {
            if let comment = comments[string] {
                processedStrings.append("/* \(comment) */ \n")
            }
            processedStrings.append("\"\(string)\" = \"\(string)\";\n")
        }

        processedStrings.removeLast()

        print(processedStrings)
    }

    // Applies regex to a file at filePath.
    mutating func localizableStringsInFile(filePath: URL) -> (Set<String>, [String: String]) {
        do {
            let fileContentsData: Data = try Data(contentsOf: filePath)
            guard
                let fileContentsString: NSString = .init(
                    data: fileContentsData,
                    encoding: String.Encoding.utf8.rawValue,
                ) else
            {
                return (Set<String>(), [String: String]())
            }

            let localizedMatches: [NSTextCheckingResult] = try regexMatches(
                pattern: localizedRegex,
                string: fileContentsString as String,
            )
            let commentedMatches: [NSTextCheckingResult] = try regexMatches(
                pattern: commentedRegex,
                string: fileContentsString as String,
            )

            let localizedStringsArray: [String] = localizedMatches.map { fileContentsString.substring(with: $0.range) }
            var comments: [String: String] = [:]
            for m in commentedMatches {
                let comment: String = fileContentsString.substring(with: m.range)
                if
                    let localizedRange = localizedMatches
                        .last(where: { $0.range.location + $0.range.length <= m.range.location })?
                        .range
                {
                    let localized: String = fileContentsString.substring(with: localizedRange)
                    comments[localized] = comment
                }
            }

            return (Set(localizedStringsArray), comments)
        } catch {
            print(error)
        }
        return (Set<String>(), [String: String]())
    }

    // MARK: Regex

    mutating func regexWithPattern(pattern: String) throws -> NSRegularExpression {
        var safeRegex: [String: NSRegularExpression] = self.regularExpresions
        if let regex: NSRegularExpression = safeRegex[pattern] {
            return regex
        }
        do {
            let currentPattern: NSRegularExpression
            currentPattern = try NSRegularExpression(
                pattern: pattern,
                options: NSRegularExpression.Options.caseInsensitive,
            )
            safeRegex.updateValue(currentPattern, forKey: pattern)
            self.regularExpresions = safeRegex
            return currentPattern
        } catch {
            throw GenstringsError.Error
        }
    }

    mutating func regexMatches(pattern: String, string: String) throws -> [NSTextCheckingResult] {
        do {
            let internalString: String = string
            let currentPattern: NSRegularExpression = try regexWithPattern(pattern: pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to
            // NSString for taking range.
            let nsString: NSString = internalString as NSString
            let stringRange: NSRange = .init(location: 0, length: nsString.length)
            return currentPattern.matches(in: internalString, options: [], range: stringRange)
        } catch {
            throw GenstringsError.Error
        }
    }

    // MARK: File manager

    func fetchFilesInFolder(rootPath: URL) -> [URL] {
        var files: [URL] = []
        do {
            let directoryContents: [URL] = try fileManager.contentsOfDirectory(
                at: rootPath as URL,
                includingPropertiesForKeys: [],
                options: .skipsHiddenFiles,
            )
            for urlPath in directoryContents {
                let stringPath: String = urlPath.path
                let lastPathComponent: String = urlPath.lastPathComponent
                let pathExtension: String = urlPath.pathExtension
                var isDir: ObjCBool = false
                if self.fileManager.fileExists(atPath: stringPath, isDirectory: &isDir) {
                    if isDir.boolValue {
                        if !self.excludedFolderNames.contains(lastPathComponent) {
                            let dirFiles: [URL] = self.fetchFilesInFolder(rootPath: urlPath)
                            files.append(contentsOf: dirFiles)
                        }
                    } else {
                        if
                            self.acceptedFileExtensions.contains(pathExtension) && !self.excludedFileNames
                                .contains(lastPathComponent)
                        {
                            files.append(urlPath)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        return files
    }
}

var genStrings: GenStrings = .init()

if CommandLine.arguments.count > 1 {
    let path: String = CommandLine.arguments[1]
    genStrings.perform(path: path)
} else {
    genStrings.perform(path: nil)
}

// swiftlint:enable legacy_objc_type
