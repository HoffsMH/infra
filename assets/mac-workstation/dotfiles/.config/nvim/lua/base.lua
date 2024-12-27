local keymap = require('keymap')
local nnoremap = keymap.nnoremap
local tnoremap = keymap.tnoremap
local vnoremap = keymap.vnoremap

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true
--
vim.opt.eol = false
vim.opt.fixeol = false
vim.opt.fixendofline = false
vim.opt.swapfile = false

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

vim.opt.showmode = false

vim.opt.clipboard = 'unnamedplus'

-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
--
vim.opt.foldmethod = "indent"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4

-- Enable break indent
vim.opt.breakindent = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

vim.api.nvim_command([[autocmd TextChanged,TextChangedI *.* silent write]])

nnoremap("<M-w>L", "<cmd>vs<cr>")
nnoremap("<M-w>J", "<cmd>hs<cr>")

-- yf will copy the path of the current file
nnoremap("<leader>yfr", "<cmd>:let @+=expand('%')<CR>")
nnoremap("<leader>yfa", "<cmd>:let @+=expand('%:p')<CR>")

-- fat thumb
nnoremap("q:", "<Nop>")

nnoremap("<M-d>", "<C-d>")
vnoremap("<M-d>", "<C-d>")
nnoremap("<M-u>", "<C-u>")
vnoremap("<M-u>", "<C-u>")

nnoremap('<Esc>', '<cmd>nohlsearch<CR>')
nnoremap('<M-e>', 'viw')
nnoremap('<leader>n', '<cmd>e #<cr>', { desc = 'goto last buffer' })

nnoremap('[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
nnoremap(']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
nnoremap('<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
nnoremap('<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

nnoremap('<leader>fd', ':!open %:p:h<CR>', { desc = "Open file explorer in current buffer's directory" })
nnoremap('<leader>fe', ':e %:p:h<CR>', { desc = "Open file explorer in current buffer's directory" })

nnoremap('<leader>b', '<cmd>:bufdo bwipeout<CR>', { desc = 'wipe out all current buffers (after checking out a different branch for instance)' })

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

return {
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  {
    'ellisonleao/gruvbox.nvim',
    name = 'gruvbox',
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'gruvbox'

      -- You can configure highlights by doing something like
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for install instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

      'nvim-telescope/telescope-live-grep-args.nvim',

      'onsails/lspkind-nvim',
    },
    config = function()
      -- The easiest way to use telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of help_tags options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      require('telescope').setup {
        defaults = {
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
          },
        },
        extensions = {
          ['ui-select'] = {
           require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable telescope extensions, if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      nnoremap('<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      nnoremap('<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

      -- - vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      nnoremap('<leader>sf', '<cmd>lua require("telescope.builtin").find_files({ hidden = true })<CR>', { noremap = true, desc = '[S]earch [F]iles' })


      nnoremap('<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      nnoremap('<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      -- nnoremap('<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      nnoremap("<leader>sg", function() require('telescope').extensions.live_grep_args.live_grep_args() end, { desc = '[S]earch by [G]rep' } )
      nnoremap('<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      nnoremap('<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      nnoremap('<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      nnoremap('<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      nnoremap('<leader>qf', builtin.quickfix, { desc = 'quickfix' })
      nnoremap('<leader>qh', builtin.quickfixhistory, { desc = 'quickfix history' })
      nnoremap('<leader>qn', function() vim.api.nvim_command('cnext')  end, { desc = 'quickfix next' })
      nnoremap('<leader>qb', function() vim.api.nvim_command('cprev')  end, { desc = 'quickfix prev' })

      -- { "<leader>qn", function() vim.api.nvim_command('cnext')  end, desc = "quickfix next" },
      -- { "<leader>qb", function() vim.api.nvim_command('cprev')  end, desc = "quickfix prev" },

      -- Slightly advanced example of overriding default behavior and theme
      nnoremap('<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- Also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}

