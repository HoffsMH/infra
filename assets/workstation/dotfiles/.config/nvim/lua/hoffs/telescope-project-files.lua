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
  else
    require"telescope.builtin".find_files(find_opts)
  end
end

return M
