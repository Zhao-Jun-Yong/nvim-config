local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

return {
  -- call: Obsidian callout block
  s("call", {
    t("> [!"), c(1, { t("NOTE"), t("TIP"), t("WARNING"), t("IMPORTANT") }),
    t({ "]", "> " }), i(2),
  }),

  -- fm: YAML frontmatter with today's date
  s("fm", {
    t({ "---", "created: " }),
    f(function() return os.date("%Y-%m-%d") end, {}),
    t({ "", "tags:", "  - " }), i(1),
    t({ "", "---", "" }),
  }),
}
