local nnoremap = require('hoffs.keymap').nnoremap
local vnoremap = require('hoffs.keymap').vnoremap

vim.g.mapleader = " "

-- keybind to switch between folding methods so I can prefer syntx

nnoremap("<leader>u", ":UndotreeShow<CR>")

nnoremap("<leader>n", "<cmd>e #<cr>")
nnoremap("<C-w>L", "<cmd>vs #<cr>")
nnoremap("<C-w>J", "<cmd>hs #<cr>")
nnoremap('<leader>gb', function() require("gitsigns").blame_line{full=true} end)

nnoremap('<leader>gy', function () require("gitlinker") end)

-- LF
nnoremap("<leader>jf", "<cmd>Lf<cr>")

-- main file finder
nnoremap('<C-p>', "<cmd>lua require('hoffs.telescope-project-files').project_files()<CR>")

nnoremap("<C-Up>", ":lua require('telescope.builtin').resume()<CR>")
nnoremap("<leader>fd", "<cmd>Telescope grep_string<cr>")
nnoremap("<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>")
nnoremap('<leader>fz', "<cmd>Telescope zoxide list<cr>")
nnoremap('<leader>fw', ":lua require('telescope').extensions.git_worktree.git_worktrees()<CR>")
nnoremap('<leader>fa', ":lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>")

-- config
nnoremap("<leader>.", "<cmd>e ~/.config/nvim<cr>")

-- fat thumb
nnoremap("q:", "<Nop>")

-- make this keep expandign
nnoremap("<C-e>", "<Plug>(expand_region_expand)")
vnoremap("<C-e>", "<Plug>(expand_region_expand)")

