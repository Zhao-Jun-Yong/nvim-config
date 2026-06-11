-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.mouse = "a"          -- mouse support (useful in Termius)
-- Explicit clipboard maps (avoid blocking pbcopy/pbpaste on every yank)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })

-- Visual-only options: VSCode draws the UI, so skip these under vscode-neovim
if not vim.g.vscode then
  vim.opt.number = true
  vim.opt.relativenumber = false
  vim.opt.termguicolors = true  -- required for true-color themes, treesitter, colorizer
  vim.opt.conceallevel = 1      -- required for obsidian.nvim UI features
end

vim.g.mapleader = " "

-- Auto-reload files changed outside Neovim (e.g. by Claude Code)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then vim.cmd("checktime") end
  end,
})

-- Reverse scroll direction for touchscreen (Terminus on iPad)
vim.keymap.set({'n', 'v', 'i'}, '<ScrollWheelUp>', '<ScrollWheelDown>')
vim.keymap.set({'n', 'v', 'i'}, '<ScrollWheelDown>', '<ScrollWheelUp>')

-- Load plugins
if vim.g.vscode then
  -- Under VSCode Neovim, load only text/motion plugins; VSCode owns the UI,
  -- completion, LSP, file tree, fuzzy finder, git gutter and outline.
  require("lazy").setup({
    { import = "plugins.editing" },  -- autopairs, Comment, jk-escape, hop, R operators
    { import = "plugins.writing" },  -- markdown keymaps + table-mode (heavy plugins self-skip)
    { import = "plugins.vscode" },  -- VSCode fallback keymaps (R sections, aerial equivalents)
  })
else
  require("lazy").setup("plugins")
end
