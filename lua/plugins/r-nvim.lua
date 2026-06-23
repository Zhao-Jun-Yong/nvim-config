local ai = require("ai")

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
            vim.keymap.set("v", "<leader>ar", function()
              local bufnr = vim.api.nvim_get_current_buf()
              local ft = vim.bo[bufnr].filetype
              vim.schedule(function()
                local s = vim.fn.line("'<")
                local e = vim.fn.line("'>")
                local lines = vim.api.nvim_buf_get_lines(bufnr, s - 1, e, false)
                if s == 0 or #lines == 0 then
                  vim.notify("AI: no text selected", vim.log.levels.WARN)
                  return
                end
                local prompt = table.concat({
                  "Fix the following R code according to these rules:",
                  "- Fix syntax errors, typos, and bugs",
                  "- Use modern dplyr 1.1+ patterns: `.by` instead of `group_by()|>ungroup()`, `join_by()` for joins, `pick()`/`across()`/`reframe()` where appropriate",
                  "- Prefer tidyverse over base R equivalents (e.g. `filter()` not `subset()`, `str_detect()` not `grepl()`)",
                  "- Use `{{}}` for column arguments in functions, `.data[[]]` for string column names",
                  "- Improve clarity and conciseness; remove redundant steps",
                  "- Follow tidyverse style: snake_case names, spaces around `=` and after commas, one verb per line in pipelines",
                  "- Preserve original logic and intent exactly",
                  "- Do not add new functionality or refactor beyond what was asked",
                  "- Preserve comments; update only if they become inaccurate after a fix",
                  "- Return only the corrected code with no explanations and no markdown code fences",
                  "- If already correct, return unchanged",
                  "",
                  table.concat(lines, "\n"),
                }, "\n")
                vim.notify("AI: fixing R code…", vim.log.levels.INFO)
                vim.fn.jobstart({ "claude", "-p", prompt }, {
                  stdout_buffered = true,
                  on_stdout = function(_, data)
                    if not data then return end
                    vim.schedule(function()
                      local raw = table.concat(data, "\n")
                      local result = raw:gsub("^%s*```.-\n", ""):gsub("\n%s*```%s*$", "")
                      ai.diff_split(lines, result, {
                        filetype = ft,
                        on_apply = function(result_lines)
                          vim.api.nvim_buf_set_lines(bufnr, s - 1, e, false, result_lines)
                        end,
                      })
                    end)
                  end,
                })
              end)
            end, { buffer = true, desc = "AI: fix R code" })
          end,
        },
        min_editor_width = 30,
        rconsole_width = 40,
      })
    end,
  },
}
