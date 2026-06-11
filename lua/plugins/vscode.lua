if not vim.g.vscode then return {} end

-- R section navigation: same search pattern as r-nvim.lua, but registered
-- here because R.nvim doesn't load under VSCode Neovim.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "quarto" },
  callback = function()
    local function r_jump(pattern)
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(pattern, true, false, true), "n", false
      )
    end
    vim.keymap.set({ "n", "v" }, "<leader>j",
      function() r_jump("/^#.*----<CR><Cmd>nohlsearch<CR>") end,
      { buffer = true, silent = true, desc = "Next R section" })
    vim.keymap.set({ "n", "v" }, "<leader>k",
      function() r_jump("?^#.*----<CR><Cmd>nohlsearch<CR>") end,
      { buffer = true, silent = true, desc = "Prev R section" })
  end,
})

-- aerial.nvim equivalents via VSCode commands.
-- <leader>[ / <leader>] map to prev/next diagnostic (closest native equivalent).
vim.keymap.set("n", "<leader>ao",
  function() vim.fn.VSCodeNotify("workbench.action.gotoSymbol") end,
  { desc = "Go to symbol" })
vim.keymap.set("n", "<leader>[",
  function() vim.fn.VSCodeNotify("editor.action.marker.prev") end,
  { desc = "Prev diagnostic" })
vim.keymap.set("n", "<leader>]",
  function() vim.fn.VSCodeNotify("editor.action.marker.next") end,
  { desc = "Next diagnostic" })

return {}
