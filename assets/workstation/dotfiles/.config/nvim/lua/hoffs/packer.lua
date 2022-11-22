-- to install packer
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim\
--  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

vim.api.nvim_command('packadd packer.nvim')

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'nvim-lua/plenary.nvim'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  use { 'ellisonleao/gruvbox.nvim', as = 'gruvbox' }
  use { 'terryma/vim-expand-region', as = 'expand_region' }

  -- use the damn % key plx
  use 'andymass/vim-matchup'
  use 'windwp/nvim-autopairs'

  use 'nvim-telescope/telescope-live-grep-args.nvim'
  use { 'nvim-telescope/telescope.nvim' }
  use 'kyazdani42/nvim-web-devicons'
  use 'terrortylor/nvim-comment'
  use 'mbbill/undotree'

  use 'voldikss/vim-floaterm'
  use 'ptzz/lf.vim'

  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }

  use {
      'ruifm/gitlinker.nvim',
      requires = 'nvim-lua/plenary.nvim',
  }

  --  Old text                    Command         New text
  -- --------------------------------------------------------------------------------
  --     surr*ound_words             ysiw)           (surround_words)
  --     *make strings               ys$"            "make strings"
  --     [delete ar*ound me!]        ds]             delete around me!
  --     remove <b>HTML t*ags</b>    dst             remove HTML tags
  --     'change quot*es'            cs'"            "change quotes"
  --     <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
  --     delete(functi*on calls)     dsf             function calls
  use({
    "kylechui/nvim-surround",
    config = function()
    end
  })
  use("ThePrimeagen/harpoon")

  -- lsp
  use 'neovim/nvim-lspconfig'

  -- cmp
  use("hrsh7th/nvim-cmp")

  -- for icons on the popup
  use("onsails/lspkind-nvim")

  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use('jvgrootveld/telescope-zoxide')

  -- use("nanotee/zoxide.vim")
end)

require("nvim-surround").setup({
  -- Configuration here, or leave empty to use defaults
    indent_lines = function(start, stop)
        local b = vim.boskdjf
        -- Only re-indent the selection if a formatter is set up already
        if start <= stop
            and (b.equalprg ~= ""
            or b.indentexpr ~= ""
            or b.cindent
            or b.smartindent
            or b.lisp) then
            vim.cmd(string.format("silent normal! %dG=%dG", start, stop))
        end
    end,
})
