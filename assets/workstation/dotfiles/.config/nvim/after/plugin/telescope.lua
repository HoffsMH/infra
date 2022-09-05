require('telescope').setup{
  defaults = {
    file_ignore_patterns = { ".git" },
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
