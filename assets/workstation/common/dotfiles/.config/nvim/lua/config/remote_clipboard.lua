-- Clipboard that follows the terminal you are attached to rather than the host
-- nvim runs on: every copy is an OSC 52 write to our own tty, which ghostty
-- turns into that machine's clipboard - through tmux or herdr, local or remote.
-- So yanking in a herdr pane on office, driven from xps, lands on xps.
--
-- Two herdr/nvim details this leans on:
--   * herdr bridges only the "c" selection, so * is routed there too rather
--     than to OSC 52's "p" (primary), which herdr drops.
--   * paste never queries the terminal. An unanswered OSC 52 read blocks nvim
--     for 10s (see :h vim.ui.clipboard.osc52), so we hand back what we last
--     copied instead. To paste the machine's real clipboard, use the
--     terminal's own paste - bracketed paste is unaffected by any of this.
local M = {}

function M.setup()
  -- '+' selects the "c" selection in nvim's own osc52 helper; '*' would be "p".
  local emit = require("vim.ui.clipboard.osc52").copy("+")
  local last = { { "" }, "v" }

  local function copy(lines, regtype)
    last = { lines, regtype }
    emit(lines)
  end

  local function paste()
    return last
  end

  vim.g.clipboard = {
    name = "osc52",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

return M
