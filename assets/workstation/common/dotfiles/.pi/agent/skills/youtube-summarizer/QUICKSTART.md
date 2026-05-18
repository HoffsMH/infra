# YouTube Summarizer — Quick Start

## One-Command Summary

```bash
pi
```

Then in the session:

```
/skill:youtube-summarizer https://www.youtube.com/watch?v=epzzALZ8oYo
```

That's it. The model will:
1. Download the transcript
2. Summarize it in 3-4 bullet points
3. Make the full transcript available for questions

## Common Tasks

### "Just summarize this video"
```
/skill:youtube-summarizer <URL>
```

### "I want a detailed breakdown"
```
/skill:youtube-summarizer <URL>
Here's what I need: 5-point summary with key insights, plus any controversial claims mentioned.
```

### "Get the full transcript"
```
/skill:youtube-summarizer <URL>
Extract only—don't summarize. I'll ask follow-up questions.
```

### "Summarize multiple videos"
```
/skill:youtube-summarizer <URL1>
/skill:youtube-summarizer <URL2>
/skill:youtube-summarizer <URL3>

Now give me a comparison table of all three.
```

## Cost Estimates

| Video | Gemini Flash | Claude Haiku |
|-------|---|---|
| 20 min | ~$0.0003 | ~$0.003 |
| 1 hour | ~$0.0013 | ~$0.012 |
| 3 hours | ~$0.004 | ~$0.036 |

Use Gemini Flash for cost. Use Claude Haiku for better summaries.

## What Needs to Happen First

Nothing—it's already set up. Your pi agent will discover the skill automatically on next restart.

If pi doesn't recognize it:
```bash
# Verify it's there
ls ~/.pi/agent/skills/youtube-summarizer/
```

## Troubleshooting

**Video not recognized?**
- Make sure you're using a full YouTube URL (youtube.com or youtu.be)
- The video must have English captions (auto or manual)

**"Command not found" error?**
- Restart pi: `pi` in a fresh terminal
- Skills load on startup

**Very slow or hanging?**
- Long videos (3+ hrs) take time. Let it run.
- You can interrupt with Ctrl+C and try again with a shorter video

## Next Steps

See **README.md** for full documentation and advanced usage.
