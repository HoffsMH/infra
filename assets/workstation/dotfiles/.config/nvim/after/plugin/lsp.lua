local nnoremap = require('hoffs.keymap').nnoremap
local lspconfig = require('lspconfig')
local cmp = require'cmp'
local lspkind = require("lspkind")

local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	path = "[Path]",
}


local function config(_config)
	return vim.tbl_deep_extend("force", {
		capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
		on_attach = function()
			nnoremap("gd", function() vim.lsp.buf.definition() end)
			-- nnoremap("K", function() vim.lsp.buf.hover() end)
			-- nnoremap("<leader>vws", function() vim.lsp.buf.workspace_symbol() end)
			-- nnoremap("<leader>vd", function() vim.diagnostic.open_float() end)
			-- nnoremap("[d", function() vim.diagnostic.goto_next() end)
			-- nnoremap("]d", function() vim.diagnostic.goto_prev() end)
			-- nnoremap("<leader>vca", function() vim.lsp.buf.code_action() end)
			-- nnoremap("<leader>vrr", function() vim.lsp.buf.references() end)
			-- nnoremap("<leader>vrn", function() vim.lsp.buf.rename() end)
			-- inoremap("<C-h>", function() vim.lsp.buf.signature_help() end)
		end,
	}, _config or {})
end

cmp.setup({
	snippet = {
		expand = function(args)
			-- For `luasnip` user.
			require("luasnip").lsp_expand(args.body)
		end,
	},

  mapping = cmp.mapping.preset.insert({
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-u>'] = cmp.mapping.scroll_docs(4),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),

  formatting = {
		format = function(entry, vim_item)
			vim_item.kind = lspkind.presets.default[vim_item.kind]
			local menu = source_mapping[entry.source.name]
			vim_item.menu = menu
			return vim_item
		end,
	},

	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
  })
})

cmp.setup.filetype('markdown', {
  enabled = false,
})

lspconfig.eslint.setup(config({
  -- to get this:
  -- npm i -g vscode-langservers-extracted
  -- project could be behind and this lsp needs higher version
  cmd = { "asdf.exec", "nodejs", "18.4.0", "vscode-eslint-language-server", "--stdio" },
}))

require'lspconfig'.ember.setup(config())
require'lspconfig'.solargraph.setup(config())
require'lspconfig'.gopls.setup(config())
