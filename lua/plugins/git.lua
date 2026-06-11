return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]h",        gs.next_hunk,                    "Next hunk")
          map("n", "[h",        gs.prev_hunk,                    "Prev hunk")
          map("n", "<leader>gh", gs.preview_hunk,                "Preview hunk")
          map("n", "<leader>gb", gs.blame_line,                  "Blame line")
          map("n", "<leader>gS", gs.stage_hunk,                  "Stage hunk")
          map("n", "<leader>gu", gs.reset_hunk,                  "Undo hunk")
        end,
      })
    end,
  },
}
