require("telescope").load_extension('zoxide')
require("telescope").load_extension("live_grep_args")
require("telescope").load_extension("git_worktree")

local actions = require('telescope.actions')
local vim = vim

changed_on_branch = function()
    local previewers = require('telescope.previewers')
    local pickers = require('telescope.pickers')
    local sorters = require('telescope.sorters')
    local finders = require('telescope.finders')
    local devicons = require"nvim-web-devicons"

    pickers.new {
        -- one day get dev icons working on this
        devicons = devicons,
        results_title = 'Modified on current branch',
        finder = finders.new_oneshot_job({'/home/hoffs/bin/g.diffed-files'}),
        sorter = sorters.get_fuzzy_file(),
        previewer = previewers.vim_buffer_cat.new {
            get_buffer_by_name = function(_, entry)
                return entry.value
            end
        }
    }:find()
end


require('telescope').setup{
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
        ["<C-w>"] = actions.send_selected_to_qflist,
      }
    },
  },
  pickers = {
      find_files = {
        mappings = {
            n = {
              ["cdo"] = function(prompt_bufnr)
                require("telescope.actions").close(prompt_bufnr)
                vim.cmd(string.format("silent lcd %s", ".."))
              end,

              ["cdn"] = function(prompt_bufnr)
                  local selection = require("telescope.actions.state").get_selected_entry()
                  local dir = vim.fn.fnamemodify(selection.path, ":p:h")
                  require("telescope.actions").close(prompt_bufnr)
                  vim.cmd(string.format("silent lcd %s", dir))
              end
            },
          },
      },
  },
}

