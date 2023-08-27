-- telescope-config.lua
local M = {}
local vim = vim

M.project_files = function()
  local git_opts = {
    show_untracked = true,
    hidden = true,
    git_command = {"git","ls-files","--exclude-standard","--cached"},
  } -- define here if you want to define something
  local find_opts = { hidden=true } -- define here if you want to define something
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require"telescope.builtin".git_files(git_opts)
    -- require"telescope.builtin".git_status(git_opts)
    -- require('telescope').extensions.frecency.frecency(find_opts)
  else
    -- require('telescope').extensions.frecency.frecency(find_opts)
    require"telescope.builtin".find_files(find_opts)
  end
end

M.changed_on_branch = function()
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

return M

