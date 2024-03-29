local vim = vim
local opt = vim.opt
local g = vim.g

opt.colorcolumn = "80"
opt.clipboard = "unnamedplus"
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = true
opt.shiftwidth = 2
opt.hlsearch = true
opt.incsearch = true
opt.autoread = true
opt.guicursor = ""

opt.smartindent = true
opt.autoindent = true
opt.nu = true

opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true
opt.wrap = false
opt.backup = false
g.netrw_banner = 0
g.lf_map_keys = 0
g.telescope_map_keys = 0

-- Give more space for displaying messages.
opt.cmdheight = 1

opt.foldmethod = "expr"
opt.foldenable = false


vim.opt.errorbells = false
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 50

-- Don't pass messages to |ins-completion-menu|.
vim.opt.shortmess:append("c")


