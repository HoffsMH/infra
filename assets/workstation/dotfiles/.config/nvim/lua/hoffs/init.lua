require("hoffs.set")
require("hoffs.packer")
require('hoffs.binds')

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

vim.api.nvim_command([[autocmd BufWritePre *.js :%s/\s\+$//e]])
vim.api.nvim_command([[autocmd BufWritePre *.rb :%s/\s\+$//e]])

vim.api.nvim_command([[highlight RedundantSpaces ctermbg=red guibg=red]])
vim.api.nvim_command([[match RedundantSpaces /\s\+$/]])

-- when entering a md wordwrap as long as the line ends in whitespace
vim.api.nvim_command([[autocmd BufEnter *.md setlocal formatoptions+=aw]])



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
      "ruby"
    },

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

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.glimmer = {
  install_info = {
    url = "~/Code/tree-sitter-glimmer",
    files = {
      "src/parser.c",
      "src/scanner.c"
    }
  },
  filetype = "hbs",
  used_by = {
    "handlebars",
    "html.handlebars"
  }
}




require"gitlinker".setup()
require('nvim-autopairs').setup()

