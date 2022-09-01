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

  use { 'nvim-telescope/telescope.nvim',
    requires = {
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
    end
  }
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

  use({
      "kylechui/nvim-surround",
      config = function()
          require("nvim-surround").setup({
              -- Configuration here, or leave empty to use defaults
          })
      end
  })

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
end)
