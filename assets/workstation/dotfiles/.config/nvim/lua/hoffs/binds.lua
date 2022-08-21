local nnoremap = require('hoffs.keymap').nnoremap

vim.g.mapleader = " "

-- keybind to switch between folding methods so I can prefer syntx

nnoremap("<leader>u", ":UndotreeShow<CR>")

nnoremap("<leader>n", "<cmd>e #<cr>")
nnoremap("<C-w>L", "<cmd>vs #<cr>")
nnoremap('<leader>hb', function() require("gitsigns").blame_line{full=true} end)
nnoremap('<leader>tb', require("gitsigns").toggle_current_line_blame)

nnoremap('<leader>gy', function () require("gitlinker") end)


-- harpoon
nnoremap("<leader>p", function() require("harpoon.ui").toggle_quick_menu() end, silent)
-- nnoremap("<leader>w", function() require("harpoon.mark").toggle_file() end, silent)

nnoremap("<leader>q", function() require("harpoon.mark").add_file() end, silent)
nnoremap("<leader>a", function() require("harpoon.ui").nav_file(1) end, silent)
nnoremap("<leader>s", function() require("harpoon.ui").nav_file(2) end, silent)
nnoremap("<leader>d", function() require("harpoon.ui").nav_file(3) end, silent)
nnoremap("<leader>f", function() require("harpoon.ui").nav_file(4) end, silent)

-- LF
nnoremap("<leader>jf", "<cmd>Lf<cr>")

-- neogit
-- nnoremap("<leader>m", "<cmd>! trun lzg<cr>")
-- nnoremap("<leader>m", function() require('neogit').open({ }) end, silent)


nnoremap("<C-p>", "<cmd>Telescope find_files hidden=true<cr>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<cr>")
nnoremap("<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>")

-- config
nnoremap("<leader>.", "<cmd>e ~/.config/nvim<cr>")

-- fat thumb
nnoremap("q:", "<Nop>")

-- make this keep expandign
nnoremap("<C-e>", "<Plug>(expand_region_expand)")




local cmp = require'cmp'



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

	-- formatting = {
	-- 	format = function(entry, vim_item)
	-- 		vim_item.kind = lspkind.presets.default[vim_item.kind]
	-- 		local menu = source_mapping[entry.source.name]
	-- 		if entry.source.name == "cmp_tabnine" then
	-- 			if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
	-- 				menu = entry.completion_item.data.detail .. " " .. menu
	-- 			end
	-- 			vim_item.kind = ""
	-- 		end
	-- 		vim_item.menu = menu
	-- 		return vim_item
	-- 	end,
	-- },

	sources = cmp.config.sources({
		-- { name = "cmp_tabnine" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
  })
})

require"gitlinker".setup()
