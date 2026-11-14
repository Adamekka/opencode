---
name: anime-clip
description: Use only when explicitly invoked to create an AV1 MP4 clip from a video link and time range, with Japanese audio, burned-in English subtitles, and a file size under 50 MB.
---

# Anime clip

Create the requested clip when invoked as `$anime-clip` with a video link and start/end times. Creating or editing this skill does not invoke it.

## Output requirements

- Japanese audio and English subtitles burned into the video are required. Never substitute another language, omit subtitles, or deliver only a selectable subtitle track.
- Encode video as AV1 in MP4 and audio as AAC. The finished file must be strictly smaller than **50,000,000 bytes**.
- Use `cut.mp4` unless the user names the output. When creating another clip alongside an existing one, use a distinct name containing its time range and report it.
- Interpret `MM:SS` and `HH:MM:SS` as elapsed playback times, including fractional seconds when supplied. Compute duration as end minus start; require `0 <= start < end`. Ask one focused question if essential input is missing or ambiguous.

## Inspect without downloading the whole source

1. Locate FFmpeg and FFprobe. Check for the `subtitles` filter and `libsvtav1` encoder. On Homebrew, `ffmpeg-full` supplies subtitle rendering; use its keg-local binary without replacing the user's linked FFmpeg.
2. Test an actual HTTP range GET, not just `HEAD` or an `Accept-Ranges` advertisement. For example, request byte `0-0` with `curl --location --range 0-0 --max-filesize 1 --max-time 15`, saving headers and body in a temporary directory. Require `206 Partial Content` and a matching `Content-Range`. The one-byte size limit prevents an ignored Range header from downloading the source.
3. Probe remote stream metadata with timeouts and bounded HTTP requests. Where supported, pass `-request_size 1048576 -initial_request_size 1048576 -multiple_requests 1` before the URL to limit individual HTTP responses. Check the installed protocol options instead of passing unsupported flags.
4. Identify the video, Japanese audio, full English dialogue subtitles, and attached fonts. Use language tags and track titles. Prefer a matching default track, then a sole matching track. Ask when multiple meaningful candidates remain, language cannot be established, or only signs/song subtitles are available. Missing required tracks are a blocker; do not silently choose the first audio/subtitle stream.
5. Confirm that the container's index permits seeking near the requested time. HTTP range support alone does not prove efficient media seeking. Check transfer statistics or request offsets. If seeking instead scans a substantial part of the source, stop that read and explain the limitation before any whole-source download.

Keep signed URLs and request logs out of committed files. Never begin with `curl -o source.mkv` or a complete download as the normal workflow.

## Fetch a local excerpt and burn its subtitles

Use a temporary directory with simple local filenames. Fetch only the selected timed streams around the requested range, then render subtitles from that local excerpt. Do **not** point FFmpeg's `subtitles` filter at the remote URL: loading subtitles that way can scan the entire video.

Preserve original timestamps during extraction with `-copyts`, `-avoid_negative_ts disabled`, and stream copy. This retains keyframe preroll and subtitle cues that started before the requested cut. Resetting or clamping those cues to zero prematurely can extend their display or overlap the next cue.

For a source whose timeline starts at zero, the extraction has this shape. This example assumes the installed HTTPS protocol help lists the request-size options; omit unsupported options and verify efficient seeking before proceeding.

```sh
ffmpeg -nostdin -n -copyts \
  -ss "$START" -t "$DURATION" \
  -rw_timeout 15000000 \
  -request_size 1048576 -initial_request_size 1048576 -multiple_requests 1 \
  -i "$URL" -to "$END" \
  -map "0:$VIDEO_INDEX" -map "0:$JAPANESE_AUDIO_INDEX" -map "0:$ENGLISH_SUBTITLE_INDEX" \
  -c copy -avoid_negative_ts disabled -map_chapters -1 excerpt.mkv
```

`START` and `END` are seconds, and `DURATION = END - START`. With `-copyts`, the output `-to` is the absolute source end timestamp, not the clip duration. For a nonzero source start time, add that baseline to the absolute trim/end timestamps while keeping input `-ss` relative to playback start.

Create the font directory with `mkdir -p fonts`, then extract required attached fonts at input open with explicit `-dump_attachment:<stream-index> fonts/font-N.ttf` or `.otf` options **before** `-i`. Generate safe local filenames instead of trusting attachment names. Do **not** map attachment streams into the excerpt: they have no timed packets and can keep the remote demuxer reading to EOF after the selected video, audio, and subtitles finish.

For ASS/SSA or other text subtitles, render from the local excerpt with its original cue timestamps and extracted fonts. Trim on the original timeline, then subtract the requested absolute start from both audio and video timestamps. For a zero-based source:

```sh
ffmpeg -nostdin -n -copyts -i excerpt.mkv -t "$DURATION" \
  -map 0:v:0 -map 0:a:0 \
  -vf "trim=start=$START:end=$END,subtitles=excerpt.mkv:si=0:fontsdir=fonts,setpts=PTS-$START/TB" \
  -af "atrim=start=$START:end=$END,asetpts=PTS-$START/TB" \
  -c:v libsvtav1 -preset 6 -crf 28 -pix_fmt yuv420p10le \
  -c:a aac -b:a 128k -sn \
  -map_metadata -1 -map_chapters -1 -metadata:s:a:0 language=jpn \
  -movflags +faststart candidate.mp4
```

Preserve the source's aspect ratio, frame rate, colors, subtitle styling, and timing. Use a local bitmap-subtitle overlay when the selected English track is image-based; the text `subtitles` filter does not support every bitmap format. Report an unsupported format rather than delivering an unsubtitled clip.

## Enforce the size limit and deliver

- Start with the quality-based AV1 encode above. Check the actual candidate size, not an estimate.
- If it is at least 50,000,000 bytes, re-encode the local excerpt using an explicit bitrate budget. Target at most 48,000,000 bytes to reserve space for the container and bitrate variation. Compute `video_bits_per_second = floor(48,000,000 * 8 / duration_seconds - audio_bits_per_second)`. Keep the audio bitrate consistent with that calculation.
- For `libsvtav1`, replace CRF mode with explicit `-b:v` bitrate control and measure the result, reducing the bitrate between attempts when needed. Recheck the final file after each encode. Limit budget retries to three; report failure if the cap still cannot be met. If the computed video bitrate is nonpositive, ask for a shorter range or an explicitly reduced audio bitrate. Ask before reducing resolution or frame rate when the available bitrate cannot produce a usable result.
- Never switch away from AV1 or use `-fs` to meet the cap. `-fs` can truncate the requested time range. Never publish an oversized candidate as a completed clip.
- Verify the final video codec is `av1`, audio is present from the selected Japanese track, duration matches the requested range within frame/codec rounding, and size is below the strict byte limit. Decode the clip to catch errors and visually inspect subtitle frames, including a cue already active at the start when present.
- Publish the verified candidate at the chosen output path, remove only temporary files created for this invocation, and return a clickable absolute file link with the time range and file size.
