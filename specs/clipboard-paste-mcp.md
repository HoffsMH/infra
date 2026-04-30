# Clipboard Paste MCP

MCP server and CLI tool for pasting clipboard images in Claude Code.

## Status

**Complete** (2026-01-28)

## Summary

Consolidated a two-layer bash/osascript clipboard solution into a pure Go implementation using the `golang.design/x/clipboard` library.

### What Was Done

1. **Researched alternatives to osascript** - Found `golang.design/x/clipboard` which uses CGo + NSPasteboard to access macOS clipboard directly

2. **Built and tested POC** - Confirmed the library correctly handles binary image data from clipboard

3. **Created `paste-cb` Go CLI** (`cmd/paste-cb/main.go`)
   - No args: paste to current directory
   - With path arg: paste to specified directory
   - Timestamp filenames: `screenshot-YYYY-MM-DD-HHMMSS.png`

4. **Updated MCP server** (`main.go`) - Now uses clipboard library directly instead of shelling out to bash script

5. **Updated install script** - Installs both CLI tool and MCP server

6. **Added `$HOME/go/bin` to PATH** in `~/.zshrc`

7. **Cleaned up old implementation**
   - Deleted `~/infra/assets/workstation/mac/dotfiles/bin/paste-cb` (bash script)
   - Deleted `~/bin/paste-cb` (symlink)

## Architecture

### Before

```
Claude Code → MCP Server (Go) → bash script → osascript → NSPasteboard
```

### After

```
Claude Code → MCP Server (Go) → golang.design/x/clipboard (CGo) → NSPasteboard
```

## File Locations

| File | Purpose |
|------|---------|
| `~/code/unpaid/clipboard-paste-mcp/main.go` | MCP server |
| `~/code/unpaid/clipboard-paste-mcp/cmd/paste-cb/main.go` | CLI tool |
| `~/code/unpaid/clipboard-paste-mcp/install.sh` | Install script |
| `~/go/bin/paste-cb` | Installed CLI binary |

## Usage

### CLI

```bash
# Paste to current directory
paste-cb

# Paste to specific directory
paste-cb /path/to/dir
```

### MCP Tool

Available in Claude Code as `paste_clipboard_screenshot` - pastes clipboard image to temp directory and returns path.

## Installation

```bash
cd ~/code/unpaid/clipboard-paste-mcp
./install.sh
```

## Dependencies

- `golang.design/x/clipboard` - Cross-platform clipboard access (uses CGo on macOS)
- `github.com/modelcontextprotocol/go-sdk/mcp` - MCP server SDK
- Xcode CLI tools (for CGo compilation)

## Context

### Why MCP and not Skills or Sub-agents?

- **MCP**: External process that gives Claude capabilities it doesn't have (clipboard access)
- **Skills**: Prompt expansions - can only use tools Claude already has
- **Sub-agents**: Spawned Claude instances - same capabilities as main Claude

Clipboard is a system resource requiring native code. MCP is the correct choice.

### Why Go clipboard library over osascript?

- Single binary, no external dependencies
- Direct NSPasteboard access via CGo
- Cleaner error handling
- Easier to extend
