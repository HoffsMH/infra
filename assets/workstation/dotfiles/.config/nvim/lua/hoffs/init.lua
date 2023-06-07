require("hoffs.set")
require("hoffs.packer")
require('hoffs.binds')

local vim = vim;

vim.api.nvim_command([[colorscheme gruvbox]])

-- one day I will figure out how to just make this work on all files everywhere
vim.api.nvim_command([[autocmd TextChanged,TextChangedI <buffer> silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.* silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.rb silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.hbs silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.lua silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.js silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.yml silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.scss silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.ex silent write]])

-- https://superuser.com/questions/299419/prevent-vim-from-clearing-the-clipboard-on-exit
vim.api.nvim_command([[autocmd VimLeave * call system("xclip -selection clipboard -o | xclip -selection clipboard")]])

vim.api.nvim_command([[autocmd BufWritePre *.js :%s/\s\+$//e]])
vim.api.nvim_command([[autocmd BufWritePre *.rb :%s/\s\+$//e]])

vim.api.nvim_command([[highlight RedundantSpaces ctermbg=red guibg=red]])
vim.api.nvim_command([[match RedundantSpaces /\s\+$/]])

-- when entering a md wordwrap as long as the line ends in whitespace
vim.api.nvim_command([[autocmd BufEnter *.md setlocal formatoptions+=aw]])
vim.api.nvim_command([[autocmd BufEnter *.md setlocal wrap]])
vim.api.nvim_create_autocmd({ "BufWritePre"}, {
  pattern = { "*.md" },
  command = [[%s/\s\+$//e]],
})

vim.api.nvim_set_hl(0, 'Search', { fg = 'LavenderBlush1', bg = 'Gray25' })
vim.api.nvim_set_hl(0, 'IncSearch', { fg = 'LavenderBlush1', bg = 'RoyalBlue4' })

vim.g.firenvim_config = {
    globalSettings = { alt = "all" },
    localSettings = {
        [".*"] = {
            cmdline  = "neovim",
            content  = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never"
        }
    }
}

vim.api.nvim_create_autocmd({'UIEnter'}, {
    callback = function(event)
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == "Firenvim" then
            vim.o.laststatus = 0
            vim.api.nvim_command([[Copilot disable]])
            vim.api.nvim_command([[set lines=20]])
            vim.api.nvim_command([[set columns=100]])
        end
    end
})

require('nvim_comment').setup({
	-- Linters prefer comment and line to have a space in between markers
	marker_padding = true,
	-- should comment out empty or whitespace only lines
	comment_empty = true,
	-- trim empty comment whitespace
	comment_empty_trim_whitespace = true,
	-- Should key mappings be created
	create_mappings = true,
	-- Normal mode mapping left hand side
	line_mapping = "gcc",
	-- Visual/Operator mapping left hand side
	operator_mapping = "gc",
	-- text object mapping, comment chunk,,
	comment_chunk_text_object = "ic",
	-- Hook function to call before commenting takes place
	hook = nil
})

require('nvim-treesitter.configs').setup {
    ensure_installed = {
      "html",
      "c",
      "lua",
      "glimmer",
      "javascript",
      "go",
      "ruby",
      "heex",
      "eex",
      "elixir"
    },
    -- auto_install = true,

    indent = {
      enable = true
    },

    highlight = {
      -- `false` will disable the whole extension
      enable = true,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = true,
    },
}


require"gitlinker".setup()
require('nvim-autopairs').setup()
require("nvim-surround").setup()
require('lualine').setup()
