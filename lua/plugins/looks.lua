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

  -- Inline color preview
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPost",
    config = function()
      require("colorizer").setup({})
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
