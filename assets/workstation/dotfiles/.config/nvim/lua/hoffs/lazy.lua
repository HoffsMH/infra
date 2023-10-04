local vim = vim
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
            "sql",
            "bash",
            "python"
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
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      vim.opt.list = true
      vim.opt.listchars:append "space: "
      vim.opt.listchars:append "eol:↴"

      vim.cmd [[highlight IndentBlanklineIndent4 guifg=#534B42 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineContextChar guifg=#689d69 gui=nocombine]]

      require("indent_blankline").setup {
        show_end_of_line = true,
        space_char_blankline = " ",
        show_current_context = true,
        char_highlight_list = {
          "IndentBlanklineIndent4",
        },
      }
    end
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      messages = {
        enabled = false, -- enables the Noice messages UI
      },
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
            end,

            ["<C-e>"] = function(prompt_bufnr)
              require("telescope.actions").smart_add_to_qflist(prompt_bufnr)
            end,
            ["<C-Down>"] = function(prompt_bufnr)
              require('telescope.actions').cycle_history_next(prompt_bufnr)
            end,

            ["<C-Up>"] = function(prompt_bufnr)
              require('telescope.actions').cycle_history_prev(prompt_bufnr)
            end,
          },

          n ={
            ["<C-w>"] = function(prompt_bufnr)
              require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
            end,

            ["<C-e>"] = function(prompt_bufnr)
              require("telescope.actions").smart_add_to_qflist(prompt_bufnr)
            end
          }
        },
      },
    },
    keys = {
      { "<leader>fg", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "find in project" },
      { "<C-p>", function() require("telescope").extensions.smart_open.smart_open() end, desc = "find files" },
      { "<leader>fd", function() require("hoffs.telescope-custom-pickers").changed_on_branch() end, desc = "changed on brach" },
      { "<C-Up>", function() require("telescope.builtin").resume() end, desc = "changed on branch" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "buffers" },
      { "<leader>fm", function() require('telescope').extensions.media_files.media_files()  end, desc = "media_files" },
      { "<leader>qf", function() require('telescope.builtin').quickfix()  end, desc = "quickfix" },
      { "<leader>qh", function() require('telescope.builtin').quickfixhistory()  end, desc = "quickfix history" },
      { "<leader>qn", function() vim.api.nvim_command('cnext')  end, desc = "quickfix next" },
      { "<leader>qb", function() vim.api.nvim_command('cprev')  end, desc = "quickfix prev" },
      { "<leader>fz", function() require('telescope').extensions.zoxide.list()  end, desc = "zoxide" },
      -- { "<C-o>", function() require('telescope').extensions.frecency.frecency() end, desc = "frecency" },
    }
  },
  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    config = function()
      require("telescope").load_extension("smart_open")
    end,
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
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
  {
    'ggandor/leap.nvim',
    config =function ()
      require('leap').add_default_mappings()
    end
  },
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
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup {
        nextls = {enable = true},
        credo = {},
        elixirls = {
          enable = true,
          settings = elixirls.settings {
            dialyzerEnabled = false,
            enableTestLenses = false,
          },
        }
      }
    end,
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
        'eslint',
        'nextls',
        'cssls',
      },
      automatic_installation = false,
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
    config = function()
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

      vim.api.nvim_command([[autocmd BufEnter *.hbs :lua vim.api.nvim_buf_set_option(0, "commentstring", "{{!-- %s --}}") ]])
    end,
  },
  {
    'mbbill/undotree',
    keys = {
      { "<leader>u", function() vim.api.nvim_command("UndotreeToggle") end, desc = "undotree" },
    }
  },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup({--[[ your config ]]})
    end,
    keys = {
      { "<leader>m", function() require('treesj').toggle() end, desc = "toggle splitjoin" },
    },
  },
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {},
    keys = {
      {
        "<leader>lg",
        function()
          local Terminal  = require('toggleterm.terminal').Terminal
          Terminal:new({ cmd = "lazygit", direction = 'float' }):toggle()
        end,
        desc = "media_files"
    },
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
    opts = {
      sections = {
        lualine_c = {
          {
            'filename',
            file_status = true,      -- Displays file status (readonly status, modified status)
            newfile_status = false,  -- Display new file status (new file means no write after created)
            path = 1,                -- 0: Just the filename
                                     -- 1: Relative path
                                     -- 2: Absolute path
                                     -- 3: Absolute path, with tilde as the home directory
                                     -- 4: Filename and parent dir, with tilde as the home directory

            shorting_target = 20,    -- Shortens path to leave 40 spaces in the window
                                     -- for other components. (terrible name, any suggestions?)
            symbols = {
              modified = '[+]',      -- Text to show when the file is modified.
              readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
              unnamed = '[No Name]', -- Text to show for unnamed buffers.
              newfile = '[New]',     -- Text to show for newly created file before first write
            }
          }
        }
      }
    },

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
    lazy = false,
    opts = {},
    keys = {
      { "<leader>gb", function() require("gitsigns").blame_line{ full=true } end, desc = "blame line" },
      { "<leader>gn", function() require("gitsigns").next_hunk{ full=true } end, desc = "blame line" },
      { "<leader>gp", function() require("gitsigns").prev_hunk{ full=true } end, desc = "blame line" },
    }
  },
}

local opts = {}

require('lazy').setup(plugins, opts)

-- function() vim.fn['firenvim#install'](0) end
