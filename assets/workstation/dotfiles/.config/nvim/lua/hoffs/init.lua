require("hoffs.set")
require("hoffs.packer")
require('hoffs.binds')

vim.api.nvim_command([[colorscheme gruvbox]])


-- one day I will figure out how to just make this work on all files everywhere
vim.api.nvim_command([[autocmd TextChanged,TextChangedI <buffer> silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.rb silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.hbs silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.lua silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.js silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.yml silent write]])
vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.scss silent write]])


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
      "c",
      "lua",
      "javascript",
      "go",
      "glimmer",
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



require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--ignore-vcs'
    },
  },
}



