# YouTube Summarizer Skill

A pi agent skill for downloading and summarizing YouTube video transcripts.

## Quick Start

### In a pi Session

Open a new pi session with your preferred model (e.g., Claude Haiku for cost-efficiency):

```bash
pi --model anthropic/claude-haiku-4.5
```

Then use the skill:

```
/skill:youtube-summarizer https://www.youtube.com/watch?v=VIDEO_ID
```

The model will handle everything:
1. Download subtitles
2. Extract clean transcript
3. Summarize in 3-4 bullet points

### In a Message

Just ask the model naturally:

```
Can you summarize this video? https://www.youtube.com/watch?v=epzzALZ8oYo
```

The model will recognize the YouTube URL and may suggest using the skill, or execute it automatically depending on your setup.

## File Structure

```
youtube-summarizer/
├── SKILL.md                         # Skill documentation
├── README.md                        # This file
└── scripts/
    └── extract-transcript.sh        # Helper script to fetch & clean transcripts
```

## Requirements

- **yt-dlp** (already installed; uses Homebrew version at `/usr/local/bin/yt-dlp`)
- **Python 3** (for text processing)
- **Internet connection** (to reach YouTube)
- **LLM API access** (whatever you have configured in pi)

## How It Works

1. **extract-transcript.sh** calls `yt-dlp` to download English subtitles in SRT format
2. SRT timestamps and sequence numbers are stripped via Python regex
3. Clean transcript text is sent to your LLM with a summarization prompt
4. Model returns structured bullet points

## Supported Videos

✅ **Works well on:**
- Tech talks and lectures (5 min - 4 hours)
- Podcasts with clear audio
- Educational content
- Documentaries
- News pieces

❌ **May not work:**
- Videos without English subtitles
- Very short clips (< 1 min) without captions
- Some livestreams
- Creator-restricted captions

## Cost Estimates

Using OpenRouter (as of May 2026):

| Video Length | Model | Estimated Cost |
|---|---|---|
| 20 min (~3K tokens) | Gemini Flash 2.0 | $0.0003 |
| 20 min (~3K tokens) | Claude Haiku 4.5 | $0.003 |
| 1 hour (~12K tokens) | Gemini Flash 2.0 | $0.0013 |
| 1 hour (~12K tokens) | Claude Haiku 4.5 | $0.012 |

**Recommendation:** Use `google/gemini-2.0-flash` for lowest cost.

## Examples

### Example 1: Simple summarization

```
User: Summarize this: https://www.youtube.com/watch?v=epzzALZ8oYo
Assistant: /skill:youtube-summarizer https://www.youtube.com/watch?v=epzzALZ8oYo
[extracts transcript]
[generates summary]
```

### Example 2: Custom summary format

```
User: /skill:youtube-summarizer https://www.youtube.com/watch?v=ABC123
Please give me 5 key takeaways, numbered and with 1-sentence explanations.
```

### Example 3: Extract for reference

```
User: Get the full transcript from https://www.youtube.com/watch?v=XYZ789
[model extracts transcript]
[you can then ask follow-up questions like "what timestamp discusses X?"]
```

## Troubleshooting

### "Failed to fetch subtitles"

**Causes:**
- Video has no English captions enabled
- Creator disabled subtitle access
- yt-dlp doesn't have permission to access YouTube

**Solutions:**
1. Verify the video has captions on youtube.com (click CC button)
2. Try a different video to confirm yt-dlp works
3. Check internet connectivity

### Transcript has duplicates

Some YouTube captions overlap or repeat. The script cleans this up but may not be perfect. The LLM's summarization usually handles this gracefully.

### Very long videos hang

If a video is > 4 hours, it may exceed token limits on smaller models. Solutions:
- Use a model with larger context (Claude Sonnet has 200K)
- Use Gemini 2.0 Flash (1M context) on OpenRouter
- Ask the model to summarize only specific sections

### yt-dlp permission error

Verify yt-dlp is installed and on PATH:

```bash
which yt-dlp
yt-dlp --version
```

If missing, install via Homebrew:

```bash
brew install yt-dlp
```

## Advanced Usage

### Manual transcript extraction (without summarization)

```bash
~/.pi/agent/skills/youtube-summarizer/scripts/extract-transcript.sh \
  "https://www.youtube.com/watch?v=VIDEO_ID" > my-transcript.txt
```

Then use the transcript separately (e.g., with search, analysis, etc.).

### Batch summarization

Create a file `videos.txt` with one URL per line:

```
https://www.youtube.com/watch?v=VIDEO1
https://www.youtube.com/watch?v=VIDEO2
https://www.youtube.com/watch?v=VIDEO3
```

Then ask the model:

```
Can you summarize each of these videos?
[paste video list]
```

The model will use the skill for each URL.

## Development Notes

To modify the skill:

1. Edit `SKILL.md` to change instructions
2. Edit `scripts/extract-transcript.sh` to change transcript extraction logic
3. Restart pi to reload the skill

The skill follows the [Agent Skills standard](https://agentskills.io/specification).
