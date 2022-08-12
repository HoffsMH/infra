local nnoremap = require('hoffs.keymap').nnoremap

vim.g.mapleader = " "

-- keybind to switch between folding methods so I can prefer syntx

nnoremap("<leader>u", ":UndotreeShow<CR>")

nnoremap("<leader>n", "<cmd>e #<cr>")
nnoremap("<C-w>L", "<cmd>vs #<cr>")
nnoremap('<leader>hb', function() require("gitsigns").blame_line{full=true} end)
nnoremap('<leader>tb', require("gitsigns").toggle_current_line_blame)
-- nnoremap('<leader>gy', require("gitlinker").toggle_current_line_blame)


-- harpoon
nnoremap("<leader>p", function() require("harpoon.ui").toggle_quick_menu() end, silent)
-- nnoremap("<leader>w", function() require("harpoon.mark").toggle_file() end, silent)

nnoremap("<leader>q", function() require("harpoon.mark").add_file() end, silent)
nnoremap("<leader>a", function() require("harpoon.ui").nav_file(1) end, silent)
nnoremap("<leader>s", function() require("harpoon.ui").nav_file(2) end, silent)
nnoremap("<leader>d", function() require("harpoon.ui").nav_file(3) end, silent)
nnoremap("<leader>f", function() require("harpoon.ui").nav_file(4) end, silent)

-- LF
nnoremap("<leader>jf", "<cmd>Lf<cr>")

-- neogit
-- nnoremap("<leader>m", "<cmd>! trun lzg<cr>")
-- nnoremap("<leader>m", function() require('neogit').open({ }) end, silent)


nnoremap("<C-p>", "<cmd>Telescope find_files hidden=true<cr>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<cr>")
nnoremap("<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>")

-- config
nnoremap("<leader>.", "<cmd>e ~/.config/nvim<cr>")

-- fat thumb
nnoremap("q:", "<Nop>")

-- make this keep expandign
nnoremap("<C-e>", "<Plug>(expand_region_expand)")

--

nnoremap("gd", function() vim.lsp.buf.definition() end)

-- require'lspconfig'.ember.setup{}
require'lspconfig'.solargraph.setup{}
-- require'lspconfig'.gopls.setup{}

-- require'lspconfig'.tsserver.setup{}
require'lspconfig'.eslint.setup{
  cmd = { "asdf.exec", "nodejs", "18.4.0", "vscode-eslint-language-server", "--stdio" },
}
--
require"gitlinker".setup()
