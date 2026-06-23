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
      backends = {
        ["_"]        = { "lsp", "treesitter" },
        ["markdown"] = { "markdown" },
      },
      layout = {
        default_direction = "float",
      },
      float = {
        max_width = 0.5,
        min_width = 0.4,
      },
      close_on_select = true,
      keymaps = {
        ["<CR>"] = function()
          require("aerial").select()
          require("aerial").close()
        end,
      },
      filter_kind = {
        ["_"]        = { "Function", "Class", "Method", "Variable" },
        ["markdown"] = { "Interface" },
      },
      show_guides = true,
    },
  },
}
