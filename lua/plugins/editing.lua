-- Copy current file's absolute path to status line and unnamed register
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg('"', path)
  print("Path: " .. path)
end, { desc = "Copy file path" })

-- R operator shortcuts
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "quarto" },
  callback = function()
    vim.keymap.set("i", "<<", "<-", { buffer = true })
    vim.keymap.set("i", ">>", "%>%", { buffer = true })
  end,
})

return {
  -- Auto-close brackets, parens, quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Comment/uncomment with gcc
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup({})
    end,
  },

  -- jk to exit insert mode
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup({
        mappings = {
          i = { j = { k = "<Esc>" } },
          v = { j = { k = "<Esc>" } },
        },
      })
    end,
  },

  -- Jump anywhere on screen
  {
    "smoka7/hop.nvim",
    keys = {
      { "<leader>hw", "<cmd>HopWord<cr>",       desc = "Hop to word" },
      { "<leader>hl", "<cmd>HopLineStart<cr>",  desc = "Hop to line" },
    },
    config = function()
      require("hop").setup({})
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>",          desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<cr>",   desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<cr>",     desc = "Git push" },
    },
  },
}
