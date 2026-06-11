local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- chunk: R code chunk
  s("chunk", {
    t("```{r "), i(1, "label"), t({ "", "" }), i(2), t({ "", "```" }),
  }),

  -- yaml: YAML frontmatter
  s("yaml", {
    t({ "---", 'title: "' }), i(1, "Title"), t({ '"', 'author: "' }), i(2, "Author"),
    t({ '"', "date: " }), i(3, "today"),
    t({ "", "output:", "  html_document:", "    toc: true", "---", "" }),
  }),
}
