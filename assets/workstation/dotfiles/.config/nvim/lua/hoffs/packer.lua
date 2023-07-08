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
  use 'github/copilot.vim'

  use 'nvim-telescope/telescope-live-grep-args.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'terrortylor/nvim-comment'
  use 'mbbill/undotree'
  use 'glacambre/firenvim'
  use 'andrewferrier/wrapping.nvim'
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'akinsho/toggleterm.nvim'
  use 'lmburns/lf.nvim'

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

  -- :h nvim-surround.usage.
  -- Furthermore, there are insert-mode *<C-g>s* and visual-mode *S* mappings, that
  -- add the delimiter pair around the cursor and visual selection, respectively.
  -- In all of the following examples, we will use `|` to demarcate the start and
  -- end of a visual selection:
  --
  --     local str = |some text|     S'              local str = 'some text'
  --     |div id="test"|</div>       S>              <div id="test"></div>
  --     local x = ({ *32 })         ds)             local x = { 32 }
  --     '*some string'              cs'"            "some string"
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
end)


