return {
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>ao", "<cmd>AerialToggle<cr>", desc = "Toggle outline sidebar" },
      { "<leader>[", "<cmd>AerialPrev<cr>", desc = "Prev symbol" },
      { "<leader>]", "<cmd>AerialNext<cr>", desc = "Next symbol" },
    },
    opts = {
      backends = { "lsp", "treesitter" },
      layout = {
        default_direction = "float",
      },
      close_on_select = true,
      keymaps = {
        ["<CR>"] = function()
          require("aerial").select()
          require("aerial").close()
        end,
      },
      filter_kind = { "Function", "Class", "Method", "Variable" },
      show_guides = true,
    },
  },
}
