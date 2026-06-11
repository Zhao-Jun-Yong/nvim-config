local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- fun: function skeleton
  s("fun", {
    i(1, "name"), t(" <- function("), i(2, "args"), t({ ") {", "  " }), i(3), t({ "", "}" }),
  }),

  -- rox: roxygen2 documentation block
  s("rox", {
    t({ "#' " }), i(1, "Title"),
    t({ "", "#'", "#' @param " }), i(2, "x"), t(" "), i(3, "Description."),
    t({ "", "#' @return " }), i(4, "Value."),
    t({ "", "#' @export", "" }),
  }),
}
