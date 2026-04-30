# Clipboard Paste MCP - Portability Audit Plan

Audit checklist to ensure the repo is ready for use on a new machine or by another user.

## 1. Hardcoded Paths ✅ COMPLETE (2026-01-28)

- [x] Search for hardcoded user paths (`/Users/mh/`, `~/code/unpaid/`) - **None found** (grep returned no matches)
- [x] Check temp directory usage - **Uses `os.TempDir()`** in main.go:26 for cross-platform compatibility
- [x] Verify install.sh uses `$HOME` or `~` expansion, not literal paths - **Confirmed** (uses `$SCRIPT_DIR`, `$HOME/go/bin`)
- [x] Check for hardcoded `$GOPATH` assumptions - **None found** (uses explicit `GOBIN=$HOME/go/bin`)

**Verification:** Tested both CLI (`paste-cb`) and MCP server (`paste_clipboard_screenshot`) end-to-end with a real clipboard screenshot. Both work correctly.

## 2. Installation Script (`install.sh`) ✅ COMPLETE (2026-01-28)

- [x] Verify it works without prior Go installation (or documents Go as prereq) - **Added prerequisite checks**: Go, Xcode CLI tools, claude CLI. Exits with helpful install instructions if missing.
- [x] Check it creates necessary directories if missing - **Added `mkdir -p $HOME/go/bin`** before `go install`
- [x] Ensure it handles existing installations gracefully (upgrade path) - **Detects existing MCP registration** and removes before re-adding
- [x] Verify permissions are set correctly on installed binaries - **Verified**: paste-cb gets 0755, screenshots get 0644
- [x] Test on fresh shell (no custom PATH modifications) - **Added PATH guidance**: Script detects if `$HOME/go/bin` is not in PATH and shows how to add it

**Verification:** Ran full install script, tested both MCP (`paste_clipboard_screenshot`) and CLI (`paste-cb`) with real clipboard screenshot. Both work correctly.

## 3. Build Dependencies ✅ COMPLETE (2026-01-28)

- [x] Document Xcode CLI tools requirement for CGo - **Already documented** in README.md Prerequisites section (lines 14-18) and Troubleshooting section (lines 131-133)
- [x] Verify `go.mod` has all dependencies pinned - **Confirmed**: All dependencies have pinned versions including `golang.design/x/clipboard v0.7.1` and `github.com/modelcontextprotocol/go-sdk v1.2.0`
- [x] Check if `go mod tidy` produces clean output - **Verified**: `go mod tidy` runs successfully. Note: It properly declares `golang.design/x/clipboard` as a direct dependency (was previously implicit)
- [x] Test `go build` works without manual dependency fetching - **Verified**: Both `go build .` (MCP server) and `go build ./cmd/paste-cb` (CLI) succeed without errors

**Verification:** Built both binaries from clean state. Both compiled successfully. End-to-end test with real clipboard screenshot: MCP tool saved to temp dir (0644 perms), CLI tool saved to specified dir (0644 perms). Both images valid PNGs.

## 4. MCP Configuration ✅ COMPLETE (2026-01-28)

- [x] Document how to add MCP server to Claude Code settings - **Added "MCP Configuration" section** to README.md explaining `claude mcp add` command and manual JSON config
- [x] Provide example `mcp_servers.json` or `settings.json` snippet - **Added JSON example** showing the exact format in `~/.claude.json`
- [x] Check if server path in config uses `$HOME` or requires absolute path - **Documented**: Absolute paths required, `~` expansion not supported in JSON config
- [x] Document any required environment variables - **Confirmed**: None required, documented in README

**Verification:** Tested both MCP tool (`paste_clipboard_screenshot`) and CLI tool (`paste-cb`) end-to-end with real clipboard screenshot. Both work correctly.

## 5. README/Documentation ✅ COMPLETE (2026-01-28)

- [x] Add comprehensive README.md if missing - **Already present**: 176-line comprehensive README
- [x] Include: Prerequisites, Installation, Usage, Troubleshooting - **All present**: Prerequisites (lines 12-19), Installation (lines 21-63), Usage (lines 102-128), Troubleshooting (lines 163-176)
- [x] Document macOS version requirements (if any) - **Documented**: Platform Support section states macOS-only, Xcode CLI tools required (implies 10.9+)
- [ ] Add example output / screenshots - **Skipped**: Low priority, CLI output documented in Usage section

## 6. Error Handling ✅ COMPLETE (2026-01-28)

- [x] Verify helpful error when clipboard is empty - **Clear message**: `No image data in clipboard` (exit code 1)
- [x] Verify helpful error when clipboard has non-image content - **Same message** as empty: `No image data in clipboard` (correct behavior - text is not image data)
- [x] Check error message when output directory doesn't exist - **Handled gracefully**: CLI uses `os.MkdirAll` to create directory automatically
- [x] Test behavior when lacking write permissions - **Clear message**: `Failed to create directory: mkdir /System/test-no-permission: operation not permitted` (exit code 1)

**Verification:** Tested all error scenarios with CLI tool (`paste-cb`). All error messages are helpful and include relevant context. MCP tool uses same error handling code paths.

## 7. Cross-Platform Considerations ✅ COMPLETE (2026-01-28)

- [x] Document that this is macOS-only (or add Linux/Windows support) - **Already documented** in README.md Platform Support section (line 159-160)
- [x] If macOS-only, add build constraints (`//go:build darwin`) - **Added** to main.go and cmd/paste-cb/main.go
- [x] Fail gracefully on unsupported platforms with clear message - **Created stub files** main_other.go and cmd/paste-cb/main_other.go that print helpful error messages on non-darwin platforms

**Verification:** Built both binaries successfully with build constraints. Tested CLI (`paste-cb`) and MCP tool (`paste_clipboard_screenshot`) end-to-end with real clipboard screenshot. Both work correctly on macOS.

## 8. Security Review ✅ COMPLETE (2026-01-28)

- [x] Verify no secrets/credentials in repo - **None found**: Grep for password/secret/key/token/credential/auth returned only oauth2 indirect dependency and documentation references
- [x] Check file permissions on created screenshots - **Correct**: Files get 0644 (`-rw-r--r--`), directories get 0755 (`drwxr-xr-x`)
- [x] Ensure temp files are created securely - **Secure**: macOS `os.TempDir()` returns user-specific `/var/folders/.../T/` with 0700 permissions, preventing other users from accessing even predictable timestamp-based subdirectories

**Verification:** Tested both MCP tool (`paste_clipboard_screenshot`) and CLI tool (`$HOME/go/bin/paste-cb`) end-to-end with real clipboard screenshot. Both created valid PNG files with correct permissions.

## 9. Testing ✅ COMPLETE (2026-01-28)

- [x] Add basic unit tests if missing - **Skipped**: Core logic is clipboard I/O (CGo/system) which can't be meaningfully unit tested without mocking system APIs. Integration tests provide better coverage.
- [x] Add integration test script - **Created `test.sh`**: Tests build, CLI paste, PNG validation, file permissions (644), filename format, and directory auto-creation (7 tests total)
- [x] Document manual testing steps - **Added to README.md**: Testing section with automated and manual testing instructions

**Verification:** Ran `./test.sh` with real clipboard screenshot - all 7 tests pass. Also verified installed `$HOME/go/bin/paste-cb` and MCP tool (`paste_clipboard_screenshot`) both work correctly end-to-end.

## 10. Git/Repo Hygiene ✅ COMPLETE (2026-01-28)

- [x] Verify `.gitignore` excludes binaries and build artifacts - **Updated**: Added `/clipboard-paste-mcp`, `/paste-cb`, `/poc/poc` with leading slashes to match root-only, plus `.DS_Store`
- [x] Check for any committed binaries that shouldn't be - **None found**: `git ls-files` shows only source files
- [x] Ensure no `.DS_Store` or IDE config files committed - **None found**: No `.DS_Store`, `.idea/`, or `.vscode/` in tracked files

**Verification:** Tested both CLI (`$HOME/go/bin/paste-cb`) and MCP tool (`paste_clipboard_screenshot`) end-to-end with real clipboard screenshot. Both created valid PNG files with correct permissions (0644).
