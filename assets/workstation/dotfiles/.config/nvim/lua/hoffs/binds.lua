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
-- yf will copy the path of the current file
nnoremap("<leader>yf", "<cmd>:let @+ = '/' . expand('%')<CR>")


nnoremap(
  "<leader>jf",
  function()
    require("lf").start(
      -- nil, -- this is the path to open Lf (nil means CWD)
              -- this argument is optional see `.start` below
      {
        -- Pass options (if any) that you would like
        dir = "", -- directory where `lf` starts ('gwd' is git-working-directory)
        direction = "float", -- window type: float horizontal vertical
        border = "double", -- border kind: single double shadow curved
        height = 0.80, -- height of the *floating* window
        width = 0.85, -- width of the *floating* window
        mappings = true, -- whether terminal buffer mapping is enabled
    })
  end,
  {noremap = true}
)

-- main file finder
nnoremap('<C-p>', "<cmd>lua require('hoffs.telescope-project-files').project_files()<CR>")
-- nnoremap("<leader>fd", ":lua require('telescope.builtin').git_status()<CR>")
nnoremap("<leader>fd", ":lua changed_on_branch()<CR>")

nnoremap("<C-Up>", ":lua require('telescope.builtin').resume()<CR>")
nnoremap("<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>")
nnoremap('<leader>fz', "<cmd>Telescope zoxide list<cr>")

-- config
nnoremap("<leader>.", "<cmd>e ~/.config/nvim<cr>")

-- fat thumb
nnoremap("q:", "<Nop>")

-- make this keep expandign
nnoremap("<C-e>", "<Plug>(expand_region_expand)")
vnoremap("<C-e>", "<Plug>(expand_region_expand)")

