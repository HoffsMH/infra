local nnoremap = require('hoffs.keymap').nnoremap

vim.g.mapleader = " "

nnoremap("<leader>n", "<cmd>e #<cr>")
nnoremap("<C-w>L", "<cmd>vs<cr>")
nnoremap("<C-w>J", "<cmd>hs<cr>")
nnoremap("<leader><S-v>", "<C-v>")

-- yf will copy the path of the current file
nnoremap("<leader>yfr", "<cmd>:let @+=expand('%')<CR>")
nnoremap("<leader>yfa", "<cmd>:let @+=expand('%:p')<CR>")

-- delete current file and buffer
nnoremap("<leader><S-d>", "<cmd>:call delete(expand('%')) | bdelete!<CR>")


-- fat thumb
nnoremap("q:", "<Nop>")


-- paste image
-- nnoremap("<leader>pi", "<cmd>:PasteImg<CR>")


