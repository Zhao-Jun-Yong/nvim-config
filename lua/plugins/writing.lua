-- Spell + wrap for prose filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "rmd", "quarto", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" }
    vim.opt_local.wrap = true
  end,
})

-- Auto-update modified: date in YAML frontmatter on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    for idx, line in ipairs(lines) do
      if line:match("^modified:") then
        vim.api.nvim_buf_set_lines(0, idx - 1, idx, false, {
          "modified: " .. os.date("%Y-%m-%d"),
        })
        break
      end
    end
  end,
})

-- Markdown-specific keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Footnote: insert [^N] at cursor and jump to definition at bottom
    vim.keymap.set("n", "<leader>fn", function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local n = 0
      for _, l in ipairs(lines) do
        if l:match("^%[%^%d+%]:") then n = n + 1 end
      end
      n = n + 1
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local cur = lines[row]
      vim.api.nvim_buf_set_lines(0, row - 1, row, false,
        { cur:sub(1, col) .. "[^" .. n .. "]" .. cur:sub(col + 1) })
      vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", "[^" .. n .. "]: " })
      vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), #("[^" .. n .. "]: ") })
      vim.cmd("startinsert!")
    end, { buffer = true, desc = "Insert footnote" })

    -- Superscript / subscript (visual selection)
    vim.keymap.set("v", "<leader>su", function()
      vim.cmd('normal! "zd')
      vim.api.nvim_put({ "<sup>" .. vim.fn.getreg("z") .. "</sup>" }, "c", false, true)
    end, { buffer = true, desc = "Wrap superscript" })
    vim.keymap.set("v", "<leader>sb", function()
      vim.cmd('normal! "zd')
      vim.api.nvim_put({ "<sub>" .. vim.fn.getreg("z") .. "</sub>" }, "c", false, true)
    end, { buffer = true, desc = "Wrap subscript" })

    -- Pandoc export (reads bibliography/csl from YAML frontmatter automatically)
    vim.keymap.set("n", "<leader>pp", function()
      local file = vim.fn.expand("%:p")
      local out  = "/Users/yangshaojun/Desktop/Workspace/000 Inbox/" .. vim.fn.expand("%:t:r") .. ".pdf"
      vim.fn.jobstart({ "pandoc", file, "-o", out, "--pdf-engine=xelatex" }, {
        on_exit = function(_, code)
          if code == 0 then vim.notify("✓ PDF: " .. out)
          else vim.notify("Pandoc failed — check :messages", vim.log.levels.ERROR) end
        end,
      })
    end, { buffer = true, desc = "Export PDF (pandoc)" })

    vim.keymap.set("n", "<leader>pw", function()
      local file = vim.fn.expand("%:p")
      local out  = "/Users/yangshaojun/Desktop/Workspace/000 Inbox/" .. vim.fn.expand("%:t:r") .. ".docx"
      vim.fn.jobstart({ "pandoc", file, "-o", out }, {
        on_exit = function(_, code)
          if code == 0 then vim.notify("✓ DOCX: " .. out)
          else vim.notify("Pandoc failed — check :messages", vim.log.levels.ERROR) end
        end,
      })
    end, { buffer = true, desc = "Export DOCX (pandoc)" })
  end,
})

-- Under VSCode Neovim, the markdown keymaps/autocmds above still apply, but the
-- UI/LSP plugins below don't (VSCode has its own zen mode, LSP and Obsidian-like
-- nav). Keep only vim-table-mode, which operates on buffer text.
if vim.g.vscode then
  return {
    {
      "dhruvasagar/vim-table-mode",
      ft = { "markdown", "rmd", "quarto" },
      config = function()
        vim.g.table_mode_corner = "|"
      end,
    },
  }
end

return {
  -- Distraction-free writing
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
    },
    opts = {
      window = { width = 80 },
    },
  },

  -- Markdown table editor (|| to create, Tab to move between cells)
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "rmd", "quarto" },
    config = function()
      vim.g.table_mode_corner = "|"
    end,
  },

  -- mason: installs marksman binary into ~/.local/share/nvim/mason/bin/
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
      vim.lsp.config("marksman", {
        cmd = { vim.fn.stdpath("data") .. "/mason/bin/marksman", "server" },
        filetypes = { "markdown", "markdown.mdx" },
        root_markers = { ".git", ".marksman.toml" },
      })
      vim.lsp.enable("marksman")
    end,
  },

  -- Obsidian vault navigation
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Find note" },
      { "<leader>on", "<cmd>ObsidianNew<cr>",         desc = "New note" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>",   desc = "Backlinks" },
      { "<leader>od", "<cmd>ObsidianToday<cr>",       desc = "Daily note" },
    },
    opts = {
      workspaces = {
        { name = "second-brain", path = "/Users/yangshaojun/Obsidian/Second Brain" },
      },
      daily_notes = {
        folder = "Calendar/Daily",
        date_format = "%Y-%m-%d",
        template = "Atlas/Extra/Template/99 Daily note template.md",
      },
      disable_frontmatter = true,
      completion = { nvim_cmp = true },
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,
    },
  },
}
