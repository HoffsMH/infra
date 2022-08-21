local nnoremap = require('hoffs.keymap').nnoremap
local lspconfig = require('lspconfig')


nnoremap("gd", function() vim.lsp.buf.definition() end)

lspconfig.eslint.setup{
  -- project could be behind and this lsp needs higher version
  cmd = { "asdf.exec", "nodejs", "18.4.0", "vscode-eslint-language-server", "--stdio" },
}

require'lspconfig'.ember.setup{}
require'lspconfig'.solargraph.setup{}
require'lspconfig'.gopls.setup{}
