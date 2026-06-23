return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-bibtex.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Search text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",   desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope bibtex<cr>",     desc = "Cite reference (parenthetical)" },
      { "<leader>fC", function()
          require("telescope").extensions.bibtex.bibtex({ format = "@%s" })
        end, desc = "Cite reference (narrative)" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config = { height = 0.9 },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
        extensions = {
          bibtex = {
            global_files = {
              "/Users/yangshaojun/Desktop/Workspace/100 Area/110 Academic/111 Literature/zotero.bib",
            },
            format = "pandoc",
            search_keys = { "label", "author", "year", "title" },
            context = true,
            context_fallback = true,
          },
        },
      })
      require("telescope").load_extension("bibtex")
    end,
  },
}
