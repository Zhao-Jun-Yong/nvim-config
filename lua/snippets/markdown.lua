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

  -- card: atomic/molecule note
  s("card", {
    t({ "---", "created: " }),
    f(function() return os.date("%Y-%m-%d") end, {}),
    t({ "", "modified:", "tags:", "  - cards/" }),
    c(1, { t("atom"), t("molecule") }),
    t({ "", "aliases:", "---", "", "up ::", "related :: ", "" }),
  }),

  -- moc: Map of Content
  s("moc", {
    t({ "---", "created: " }),
    f(function() return os.date("%Y-%m-%d") end, {}),
    t({ "", "modified:", "tags:", "  - cards/moc", "aliases:", "---", "", "up :: " }),
    i(1),
    t({ "", "related ::", "", "```dataview", "table", 'without id file.inlinks as "Cards"', "where file.name = this.file.name", "```", "" }),
  }),

  -- src: source note (book/event/lecture/people)
  s("src", {
    t({ "---", "created: " }),
    f(function() return os.date("%Y-%m-%d") end, {}),
    t({ "", "modified:", "title: " }),
    f(function() return vim.fn.expand("%:t:r") end, {}),
    t({ "", "author:", "description:", "tags: cards/" }),
    c(1, { t("book"), t("event"), t("lecture"), t("people") }),
    t({ "", "---", "", "up ::", "related ::", "" }),
  }),

  -- proj: project/effort note
  s("proj", {
    t({ "---", "created: " }),
    f(function() return os.date("%Y-%m-%d") end, {}),
    t({ "", "modified:", "title: " }),
    f(function() return vim.fn.expand("%:t:r") end, {}),
    t({ "", "author: Zhao-Jun Yong", "description:", "tags: area/" }),
    c(1, { t("academic"), t("school"), t("life") }),
    t({ "", "status: to-start", "bibliography: /Users/yangshaojun/Desktop/Workspace/100 Area/110 Academic/111 Literature/zotero.bib", "---", "", "up ::", "related ::", "", "# Tasks", "", "- [ ] " }),
    i(2),
  }),

  -- fm: YAML frontmatter with today's date
  s("fm", {
    t({ "---", "created: " }),
    f(function() return os.date("%Y-%m-%d") end, {}),
    t({ "", "tags:", "  - " }), i(1),
    t({ "", "bibliography: /Users/yangshaojun/Desktop/Workspace/100 Area/110 Academic/111 Literature/zotero.bib", "---", "" }),
  }),
}
