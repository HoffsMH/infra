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
  use 'andymass/vim-matchup'
  use 'rstacruz/vim-closer'
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
  use 'ThePrimeagen/harpoon'
  use 'neovim/nvim-lspconfig'
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
end)
