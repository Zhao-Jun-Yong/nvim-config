return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- New API: setup only accepts install_dir, no ensure_installed/highlight
    config = function()
      require("nvim-treesitter").setup({})
      -- New API doesn't enable highlight automatically — do it per filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "r", "rmd", "quarto" },
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
  {
    "R-nvim/R.nvim",
    ft = { "r", "rmd", "quarto" },
    config = function()
      require("r").setup({
        R_app = "radian",
        R_args = {},
        bracketed_paste = true,
        hook = {
          on_filetype = function()
            vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
            vim.keymap.set("v", "<Enter>", function()
              local start_line = vim.fn.line("'<")
              local end_line = vim.fn.line("'>")
              local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
              require("r.send").source_lines(lines, nil)
            end, { buffer = true })
            local function r_jump(pattern)
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(pattern, true, false, true), "n", false
              )
            end
            vim.keymap.set({ "n", "v" }, "<leader>j", function() r_jump("/^#.*----<CR><Cmd>nohlsearch<CR>") end, { buffer = true, silent = true, desc = "Next R section" })
            vim.keymap.set({ "n", "v" }, "<leader>k", function() r_jump("?^#.*----<CR><Cmd>nohlsearch<CR>") end, { buffer = true, silent = true, desc = "Prev R section" })
          end,
        },
        min_editor_width = 30,
        rconsole_width = 40,
      })
    end,
  },
}
