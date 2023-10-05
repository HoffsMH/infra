require('hoffs.set')
require('hoffs.lazy')
require('hoffs.binds')
require('plugin.lsp')

local vim = vim;

vim.api.nvim_command([[colorscheme gruvbox]])

-- one day I will figure out how to just make this work on all files everywhere
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.* silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.rb silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.hbs silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.lua silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.js silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.yml silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.scss silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.ex silent write]])
vim.api.nvim_command([[autocmd StdinReadPre * set buftype=nofile]])

-- https://superuser.com/questions/299419/prevent-vim-from-clearing-the-clipboard-on-exit
vim.api.nvim_command([[autocmd VimLeave * call system("xclip -selection clipboard -o | xclip -selection clipboard")]])

-- remove trailing whitespace on save
-- vim.api.nvim_command([[autocmd BufWritePre *.js :%s/\s\+\ze\($\|\n\)//e]])
-- vim.api.nvim_command([[autocmd BufWritePre *.hbs :%s/\s\+\ze\($\|\n\)//e]])
-- vim.api.nvim_command([[autocmd BufWritePre *.rb :%s/\s\+$//e]])
-- vim.api.nvim_create_autocmd({ "BufWritePre"}, {
--   pattern = { "*.md" },
--   command = [[%s/\s\+$//e]],
-- })

vim.api.nvim_command([[autocmd BufWritePre *.js :%s/\s\+\ze\($\|\n\)//e]])
vim.api.nvim_command([[autocmd BufWritePre *.hbs :%s/\s\+\ze\($\|\n\)//e]])
vim.api.nvim_command([[autocmd BufWritePre *.rb :%s/\s\+$//e]])
vim.api.nvim_create_autocmd({ "BufWritePre"}, {
  pattern = { "*.md" },
  command = [[%s/\s\+$//e]],
})

vim.api.nvim_command([[highlight RedundantSpaces ctermbg=red guibg=red]])
vim.api.nvim_command([[match RedundantSpaces /\s\+$/]])

-- when entering a md wordwrap as long as the line ends in whitespace
vim.api.nvim_command([[autocmd BufEnter *.md setlocal formatoptions+=aw]])
vim.api.nvim_command([[autocmd BufEnter *.md setlocal wrap]])

-- set tabstop and shiftwidth for markdown files
vim.api.nvim_command([[
  autocmd FileType markdown setlocal tabstop=2 shiftwidth=2 expandtab
]])

vim.api.nvim_set_hl(0, 'Search', { fg = 'LavenderBlush1', bg = 'Gray25' })
vim.api.nvim_set_hl(0, 'IncSearch', { fg = 'LavenderBlush1', bg = 'RoyalBlue4' })

