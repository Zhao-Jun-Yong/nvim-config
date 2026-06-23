return {
  -- Animated notifications
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        timeout = 3000,
        render = "compact",
      })
      vim.notify = require("notify")
    end,
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = false },
      })
    end,
  },

  -- Modern command line and notifications UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
        },
      })
    end,
  },

  -- Comment highlighting (ALERT, QUERY, NOTE, TODO, DEAD)
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    config = function()
      require("todo-comments").setup({
        signs = false,
        keywords = {
          ALERT = { icon = "󰀪", color = "#cc6666" },            -- warning triangle
          QUERY = { icon = "󰋗", color = "#81a2be" },            -- help circle
          NOTE  = { icon = "󰍨", color = "#b5bd68", alt = { "INFO" } },  -- note
          TODO  = { icon = "󰄵", color = "#f0c674" },            -- checkbox
          DEAD  = { icon = "󰩺", color = "#969896" },            -- trash / dead code
          FIXME = { icon = "", color = "#cc6666", alt = { "FIX", "BUG" } }, -- bug
        },
        highlight = {
          pattern = [[.*<(KEYWORDS)\s*:]],
          keyword = "fg",
          after = "fg",
        },
      })
      vim.keymap.set("n", "<leader>ft", function()
        local Config = require("todo-comments.config")
        local Highlight = require("todo-comments.highlight")
        local make_entry = require("telescope.make_entry")
        local cwd = vim.fn.getcwd() .. "/"
        local opts = {
          search_dirs = { vim.fn.expand("%:p") },
          vimgrep_arguments = vim.list_extend(
            { Config.options.search.command },
            Config.options.search.args
          ),
          search = Config.search_regex(vim.tbl_keys(Config.keywords)),
          prompt_title = "Find Todo",
          use_regex = true,
        }
        local base_maker = make_entry.gen_from_vimgrep(opts)
        opts.entry_maker = function(line)
          local ret = base_maker(line)
          ret.display = function(entry)
            local fname = entry.filename:gsub("^" .. vim.pesc(cwd), "")
            local display = string.format("%s:%s:%s ", fname, entry.lnum, entry.col)
            local text = entry.text
            local start, finish, kw = Highlight.match(text)
            local hl = {}
            if start then
              kw = Config.keywords[kw] or kw
              local icon = (Config.options.keywords[kw] or {}).icon or " "
              display = icon .. " " .. display
              table.insert(hl, { { 0, #icon + 1 }, "TodoFg" .. kw })
              text = vim.trim(text:sub(start))
              table.insert(hl, { { #display, #display + finish - start + 2 }, "TodoBg" .. kw })
              table.insert(hl, { { #display + finish - start + 1, #display + finish + 1 + #text }, "TodoFg" .. kw })
              display = display .. " " .. text
            end
            return display, hl
          end
          return ret
        end
        require("telescope.builtin").grep_string(opts)
      end, { desc = "Find TODOs (current file)" })
    end,
  },

  -- Startup dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function set_rlab_hl()
        vim.api.nvim_set_hl(0, "RLabGreen", { fg = "#b5bd68" })
      end
      set_rlab_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_rlab_hl })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dashboard",
        callback = function()
          vim.fn.matchadd("RLabGreen", [[^\s*\zs[█╗╔╝╚═║]\+\(\s\{1,3}[█╗╔╝╚═║]\+\)*\ze\s\{4,}]])
        end,
      })
      vim.keymap.set('n', '<leader>d', function()
        vim.cmd('enew')
        vim.cmd('Dashboard')
      end, { silent = true, desc = "Dashboard" })
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = {
            "",
            "  ██████╗     ██╗      █████╗ ██████╗ ",
            "  ██╔══██╗    ██║     ██╔══██╗██╔══██╗",
            "  ██████╔╝    ██║     ███████║██████╔╝",
            "  ██╔══██╗    ██║     ██╔══██║██╔══██╗",
            "  ██║  ██║    ███████╗██║  ██║██████╔╝",
            "  ╚═════╝     ╚══════╝╚═╝  ╚═╝╚═════╝ ",
            "",
          },
          center = {
            { icon = "  ", key = "f", desc = "Find File",    action = function() require("telescope.builtin").find_files() end },
            { icon = "  ", key = "r", desc = "Recent Files", action = function() require("telescope.builtin").oldfiles() end },
            { icon = "  ", key = "g", desc = "Find Text",    action = function() require("telescope.builtin").live_grep() end },
            { icon = "  ", key = "e", desc = "File Tree",    action = function() require("neo-tree.command").execute({ toggle = true }) end },
            { icon = "  ", key = "q", desc = "Quit",         action = function() vim.cmd("qa") end },
          },
          footer = {},
        },
      })
    end,
  },
}
