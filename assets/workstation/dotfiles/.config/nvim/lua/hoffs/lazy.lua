local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)


vim.g.mapleader = " "
vim.api.nvim_command([[autocmd BufEnter *.hbs :lua vim.api.nvim_buf_set_option(0, "commentstring", "{{!-- %s --}}") ]])
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

local plugins = {
  ----------------------------------------
  -- base
  'nvim-lua/plenary.nvim',

  ----------------------------------------
  -- editing base
  -- highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    name = 'nvim-treesitter.configs',
    config = function()
      require('nvim-treesitter.configs').setup{
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
            "elixir",
            "scss",
            "sql",
            "bash",
          },
          auto_install = true,

          indent = {
            enable = true
          },
          disable = function(_lang, buf)
                  local max_filesize = 1000 * 1024 -- 1 MB
                  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                  if ok and stats and stats.size > max_filesize then
                      return true
                  end
              end,

          highlight = {
            enable = true,

            additional_vim_regex_highlighting = true,
          },
      }
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
      }
  },

  -- {
  --   'Wansmer/treesj',
  --   keys = { '<space>m' },
  --   config = function() require('treesj').setup({--[[ your config ]]}) end,
  -- },

  -- finding files and text
  --
  {
    'nvim-telescope/telescope.nvim',
    name = 'telescope',
    dependencies = {
      'nvim-telescope/telescope-live-grep-args.nvim',
      'nvim-telescope/telescope-media-files.nvim',
      'jvgrootveld/telescope-zoxide',
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua" },
      },
    },
    opts = {
      defaults = {
        layout_config = {
          width = 0.9,
          preview_cutoff = 10,
          preview_width = 0.5,
        },
        file_ignore_patterns = { "deps", "_build", ".elixir_ls"},
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--ignore-vcs',
          '--ignore-file',
          '.gitignore',
        },
        mappings = {
          i ={
            ["<C-w>"] = function(prompt_bufnr)
              require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
            end
          },

          n ={
            ["<C-w>"] = function(prompt_bufnr)
              require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
            end
          }
        },
      },
    },
    keys = {
      { "<leader>fg", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "find in project" },
      { "<C-p>", function() require("hoffs.telescope-custom-pickers").project_files() end, desc = "find files" },
      { "<leader>fd", function() require("hoffs.telescope-custom-pickers").changed_on_branch() end, desc = "changed on brach" },
      { "<C-Up>", function() require("telescope.builtin").resume() end, desc = "changed on branch" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "buffers" },
      { "<leader>fm", function() require('telescope').extensions.media_files.media_files()  end, desc = "media_files" },
      { "<leader>qf", function() require('telescope.builtin').quickfix()  end, desc = "quickfix" },
      { "<leader>qh", function() require('telescope.builtin').quickfixhistory()  end, desc = "quickfix history" },
      { "<leader>qn", function() vim.api.nvim_command('cnext')  end, desc = "quickfix next" },
      { "<leader>qb", function() vim.api.nvim_command('cprev')  end, desc = "quickfix prev" },
      { "<leader>fz", function() require('telescope').extensions.zoxide.list()  end, desc = "zoxide" },
      { "<C-o>", function() require('telescope').extensions.frecency.frecency() end, desc = "frecency" },
    }
  },
  {
    'ThePrimeagen/harpoon',
    keys = {
      { "<leader>a", function() require("harpoon.mark").add_file()  end, desc = "" },
      { "<leader>s", function() require("harpoon.ui").toggle_quick_menu()  end, desc = "" },
      { "<leader>z", function() require("harpoon.ui").nav_file(1)  end, desc = "" },
      { "<leader>x", function() require("harpoon.ui").nav_file(2)  end, desc = "" },
      { "<leader>c", function() require("harpoon.ui").nav_file(3)  end, desc = "" },
      { "<leader>v", function() require("harpoon.ui").nav_file(4)  end, desc = "" },
    }
  },
  { 'terryma/vim-expand-region',
    name = 'expand_region',
    keys = {
      { "<C-e>", "<Plug>(expand_region_expand)",  mode = "v"},
      { "<C-e>", "<Plug>(expand_region_expand)", mode = "n"},
    }
  },
  'andymass/vim-matchup',

  -- TO TRY
  -- use 'ggandor/leap.nvim'
  -- use 'phaazon/hop.nvim'
  -- use 'flash'
  -- use 'flit'

  -- lsp management
  {
    'VonHeikemen/lsp-zero.nvim',
    config = function()
      local lsp = require('lsp-zero').preset({})
      lsp.on_attach(function(client, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        lsp.default_keymaps({buffer = bufnr})
      end)
    end,
    keys = {
      { "K", function() vim.lsp.buf.hover()  end, desc = "def" },
      { "gd", function() vim.lsp.buf.definition()  end, desc = "def" },
      { "gD", function() vim.lsp.buf.declaration()  end, desc = "def" },
      { "go", function() vim.lsp.buf.type_definition()  end, desc = "def" },
      { "gr", function() vim.lsp.buf.references()  end, desc = "def" },
    }
  },
  'neovim/nvim-lspconfig',
  {
    'williamboman/mason.nvim',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        -- Replace these with whatever servers you want to install
        'lua_ls',
        'solargraph',
        'gopls',
        'glint',
        'tailwindcss',
        'ember',
        'eslint',
        'elixirls',
      }
    }
  },

  -- completion
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'github/copilot.vim',
  'L3MON4D3/LuaSnip',

  ----------------------------------------
  -- editing niceties
  {
    'terrortylor/nvim-comment',
    name = 'nvim_comment',
    opts = {
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
    },
  },
  {
    'mbbill/undotree',
    keys = {
      { "<leader>u", function() vim.api.nvim_command("UndotreeToggle") end, desc = "undotree" },
    }
  },
  {
    'lmburns/lf.nvim',
    dependencies ={
      'akinsho/toggleterm.nvim',
    },
    opts = {
      -- Pass options (if any) that you would like
      dir = "", -- directory where `lf` starts ('gwd' is git-working-directory)
      direction = "float", -- window type: float horizontal vertical
      border = "double", -- border kind: single double shadow curved
      -- height = 0.80, -- height of the *floating* window
      -- width = 0.85, -- width of the *floating* window
      mappings = true, -- whether terminal buffer mapping is enabled
      env = {},
    },
    keys = {
      { "<leader>jf", function() require("lf").start()  end, desc = "media_files" },
    }
  },
  {
    'ruifm/gitlinker.nvim',
    opts = {},
    keys = {
      { "<leader>gy", function () require("gitlinker") end, desc = "gitlinker" },
    }
  },
  'nvim-lua/plenary.nvim',
  {
    'kylechui/nvim-surround',
    opts = {}
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  {
    'goolord/alpha-nvim',
    config = function ()
      require'alpha'.setup(require'alpha.themes.startify'.config)
    end
  },

  ----------------------------------------
  -- visual niceties
  'kyazdani42/nvim-web-devicons',
  -- for icons on the completion popup
  'onsails/lspkind-nvim',
  -- colorscheme
  { 'ellisonleao/gruvbox.nvim', name = 'gruvbox' },
  {
    'nvim-lualine/lualine.nvim',
    opts = {},
  },

  ----------------------------------------
  -- Note taking
  {
    -- not working atm
    'ekickx/clipboard-image.nvim',
    opts = {},
    keys = {
      { "<leader>pi", function() require("clipboard-image").paste_img() end, desc = "paste image" },
    }
  },
  'andrewferrier/wrapping.nvim',

  {
    'windwp/nvim-autopairs',
    opts = {}
  },

  ----------------------------------------
  -- Misc
  {
    'glacambre/firenvim',
    config = function()
      vim.g.firenvim_config = {
        globalSettings = {
          alt = 'all',
        },
        localSettings = {
          ['.*'] = {
            cmdline = 'neovim',
            content = 'text',
            priority = 0,
            selector = 'textarea',
            takeover = 'never',
          },
        },
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
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {},
    keys = {
      { "<leader>gb", function() require("gitsigns").blame_line{full=true} end, desc = "blame line" },
    }
  },
}
local opts = {}

require('lazy').setup(plugins, opts)

-- function() vim.fn['firenvim#install'](0) end
