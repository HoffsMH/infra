local nnoremap = require('hoffs.keymap').nnoremap
local lspconfig = require('lspconfig')
local cmp = require'cmp'
local lspkind = require("lspkind")
local vim = vim;

local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	path = "[Path]",
}

-- local function config(_config)
-- 	return vim.tbl_deep_extend("force", {
-- 		capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
-- 		on_attach = function()
-- 			nnoremap("gd", function() vim.lsp.buf.definition() end)
-- 			nnoremap("K", function() vim.lsp.buf.hover() end)
-- 			-- nnoremap("<leader>vws", function() vim.lsp.buf.workspace_symbol() end)
-- 			nnoremap("<leader>vd", function() vim.diagnostic.open_float() end)
-- 			-- nnoremap("[d", function() vim.diagnostic.goto_next() end)
-- 			-- nnoremap("]d", function() vim.diagnostic.goto_prev() end)
-- 			-- nnorrmap("<leader>vca", function() vim.lsp.buf.code_action() end)
-- 			nnoremap("<leader>vrr", function() vim.lsp.buf.references() end)
-- 			-- nnoremap("<leader>vrn", function() vim.lsp.buf.rename() end)
-- 			-- inoremap("<C-h>", function() vim.lsp.buf.signature_help() end)
-- 		end,
-- 	}, _config or {})
-- end

local ls = require("luasnip");

cmp.setup({
  snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        ls.lsp_expand(args.body) -- For `luasnip` users.
      end,
  },

	formatting = {
		format = function(entry, vim_item)
			vim_item.kind = lspkind.presets.default[vim_item.kind]
			local menu = source_mapping[entry.source.name]
			vim_item.menu = menu
			return vim_item
		end,
	},

	sources = cmp.config.sources({
		{ name = "nvim_lsp", keyword_length = 2 },
		{ name = "buffer", keyword_length = 2 },
  })
})

cmp.setup.filetype('markdown', {
  enabled = true,
	sources = cmp.config.sources({
		{ name = "nvim_lsp", keyword_length = 2 },
  })
})

local lspz = require('lsp-zero').preset({})

-- https://gist.github.com/groig/12aeb66f6191383b5711df456429ac3c
lspz.configure('tailwindcss', {
  root_dir = lspconfig.util.root_pattern(
    'assets/tailwind.config.js',
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'tailwind.config.ts',
    'postcss.config.js',
    'postcss.config.cjs',
    'postcss.config.mjs',
    'postcss.config.ts',
    'package.json',
    'node_modules',
    '.git'
  ),
	init_options = {
		userLanguages = {
			elixir = "html-eex",
      eelixir = "html-eex",
			heex = "html-heex",
		},
	},
	handlers = {
		["tailwindcss/getConfiguration"] = function(_, _, params, _, bufnr, _)
			vim.lsp.buf_notify(bufnr, "tailwindcss/getConfigurationResponse", { _id = params._id })
		end,
	},
	settings = {
		includeLanguages = {
			typescript = "javascript",
			typescriptreact = "javascript",
			["html-eex"] = "html",
			["phoenix-heex"] = "html",
			heex = "html",
      elixir = "html",
			eelixir = "html",
			elm = "html",
			erb = "html",
			svelte = "html",
		},
		tailwindCSS = {
			lint = {
				cssConflict = "warning",
				invalidApply = "error",
				invalidConfigPath = "error",
				invalidScreen = "error",
				invalidTailwindDirective = "error",
				invalidVariant = "error",
				recommendedVariantOrder = "warning",
			},
			experimental = {
				classRegex = {
					[[class= "([^"]*)]],
					[[class: "([^"]*)]],
          'class[:]\\s*"([^"]*)"',
					'~H""".*class="([^"]*)".*"""',
				},
			},
			validate = true,
		},
	},
	filetypes = {
		"css",
		"scss",
		"sass",
		"html",
		"heex",
		"elixir",
    "eelixir",
		"eruby",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"svelte",
	},
})

lspz.setup()

