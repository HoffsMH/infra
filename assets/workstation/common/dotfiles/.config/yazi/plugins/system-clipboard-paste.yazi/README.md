# system-clipboard-paste.yazi

Paste files from the system clipboard into the current directory using the ClipBoard (cb) tool.

## Requirements

- [ClipBoard](https://github.com/Slackadays/ClipBoard) - installed via Homebrew as `clipboard`
- `paste-cb` script - handles both image data (screenshots) and files

## Configuration

Add this keymap to your `keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = "P"
run = "plugin system-clipboard-paste"
desc = "Paste files from system clipboard"
```

## Features

- Pastes files copied with `cb copy`
- Extracts screenshots from clipboard and saves as PNG files
- Works with macOS clipboard (screenshots taken with Cmd+Shift+Control+4)
