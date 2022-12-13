local ls = require('luasnip')
local types = require('luasnip.util.types')
local vim = vim

-- create snippet
-- s(context, nodes, condition, ...)
local snippet = ls.s

-- This is the simplest node.
--  Creates a new text node. Places cursor after node by default.
--  t { "this will be inserted" }
--
--  Multiple lines are by passing a table of strings.
--  t { "line 1", "line 2" }
local t = ls.text_node

-- Insert Node
--  Creates a location for the cursor to jump to.
--      Possible options to jump to are 1 - N
--      If you use 0, that's the final place to jump to.
--
--  To create placeholder text, pass it as the second argument
--      i(2, "this is placeholder text")
local i = ls.insert_node

-- Function Node
--  Takes a function that returns text
local f = ls.function_node

-- This a choice snippet. You can move through with <c-l> (in my config)
--   c(1, { t {"hello"}, t {"world"}, }),
--
-- The first argument is the jump position
-- The second argument is a table of possible nodes.
--  Note, one thing that's nice is you don't have to include
--  the jump position for nodes that normally require one (can be nil)
local c = ls.choice_node

local d = ls.dynamic_node

-- TODO: Document what I've learned about lambda
local l = require("luasnip.extras").lambda

local events = require "luasnip.util.events"

-- local str_snip = function(trig, expanded)
--   return ls.parser.parse_snippet({ trig = trig }, expanded)
-- end

local same = function(index)
  return f(function(args)
    return args[1]
  end, { index })
end

local toexpand_count = 0

require("luasnip.loaders.from_vscode").lazy_load()

ls.snippets = {
  all = {
    ls.parser.parse_snippet("def", "hii")
  },
  ex = {
    ls.parser.parse_snippet("def", "hii")
  },

  lua = {
    ls.parser.parse_snippet("def", "hii")
  }
}

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
}


ls.add_snippets("all", {
  -- snippet("simple", t "wow, $1 you were $2 right!"),

  -- callbacks table
  -- snippet("toexpand", c(1, { t "hello", t "world", t "last" })),
  --
  snippet({ trig = "date" }, {
    f(function()
      return string.format(string.gsub(vim.bo.commentstring, "%%s", " %%s"), os.date())
    end, {}),
  }),

  -- snippet("for", {
  --   t "for ",
  --   i(1, "k, v"),
  --   t " in ",
  --   i(2, "ipairs()"),
  --   t { "do", "  " },
  --   i(0),
  --   t { "", "" },
  --   t "end",
  -- }),
  --
  -- snippet("def", {
  --   t "def ",
  --   i(1, "name"),
  --   i(2, "() "),
  --   t { "do", "" },
  --   i(0),
  --   t { "", "" },
  --   t "end",
  -- }),
})

vim.keymap.set({ "i", "s" }, "<c-j>", function ()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-k>", function ()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set(
  { "n" },
  "<leader><C-s>",
  "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<CR>"
)



