---
name: youtube-summarizer
description: Download YouTube video transcripts and summarize them. Use when given a YouTube URL to extract subtitles and generate a concise summary of the content.
---

# YouTube Summarizer

Automatically fetches auto-generated subtitles from any YouTube video, extracts clean transcript text, and summarizes the content into structured bullet points.

## How It Works

1. Downloads English auto-generated (or manual) subtitles using `yt-dlp`
2. Converts SRT to clean text (removes timestamps and sequence numbers)
3. Sends transcript to Claude for summarization

## Setup (One-Time)

Ensure `yt-dlp` is installed:

```bash
# Already installed on this system (via Homebrew), but to verify:
which yt-dlp
```

No API keys needed—uses your existing LLM connection (OpenRouter, etc.).

## Usage

### Quick Summary

```bash
/skill:youtube-summarizer https://www.youtube.com/watch?v=VIDEO_ID
```

The model will automatically:
1. Extract the transcript using the script
2. Generate a 3-4 bullet-point summary

### Manual Multi-Step (if needed)

```bash
# Extract transcript only (saves to transcript.txt)
{baseDir}/scripts/extract-transcript.sh "https://www.youtube.com/watch?v=VIDEO_ID" > transcript.txt

# Then ask the model to summarize the file content
```

## Examples

**Example 1: Summarize a tech talk**
```
/skill:youtube-summarizer https://www.youtube.com/watch?v=epzzALZ8oYo
```

**Example 2: Custom output format**
```
/skill:youtube-summarizer https://www.youtube.com/watch?v=ABC123
Please summarize in exactly 5 key takeaways, numbered 1-5.
```

## What You Get

- **Concise summary** of the video's main points (3-4 bullets)
- **Full transcript** is available for follow-up questions
- **Token count** to estimate summarization cost on your LLM
- Works with videos of **any length** (up to ~200K token context)

## Limitations

- Requires **English subtitles** (auto-generated or manual)
- Videos without captions will fail
- Works best on videos **5 min - 4 hours** in length
- Some videos may have auto-captions disabled by creator

## Troubleshooting

**"Failed to fetch subtitles"**
- The video may not have English captions enabled
- Try enabling captions in YouTube's subtitle settings
- Some livestreams don't support yt-dlp extraction

**Very long videos (3+ hours)**
- Still works, but may approach token limits on smaller models
- Use Claude Haiku or Gemini Flash on OpenRouter for best cost
- Summary will still capture main themes despite length

## Reference

### Transcript Quality

The extracted transcript is duplicated (captions sometimes overlap). The script cleans this up but may still show some repetition in technical content or music-heavy videos.

### Supported Subtitle Sources

- YouTube auto-generated captions (English)
- Manual captions uploaded by creator
- Community-contributed captions

### Cost Estimate

- **20-minute video** (~3K tokens): $0.002-0.015 depending on model
- **1-hour video** (~12K tokens): $0.01-0.060 depending on model
- **3-hour video** (~36K tokens): $0.03-0.18 depending on model

Use `google/gemini-2.0-flash` on OpenRouter for lowest cost.
