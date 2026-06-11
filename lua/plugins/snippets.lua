return {
  -- Load at startup so cmp-nvim-lsp's InsertEnter hook is registered before
  -- the first insert. r_ls attaches at file-open, so a lazy (InsertEnter) load
  -- would miss it and the `nvim_lsp` source would never register.
  { "hrsh7th/cmp-nvim-lsp", lazy = false },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")
      ls.config.set_config({
        history = true,
        updateevents = "InsertLeave",
      })

      -- Quarto files get all Rmd snippets
      ls.filetype_extend("quarto", { "rmd" })

      -- Tab: expand or jump forward through nodes
      vim.keymap.set({ "i", "s" }, "<Tab>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, { silent = true })

      -- Shift-Tab: jump backward
      vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true })

      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets" })
    end,
  },

  -- Completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "jmbuhr/cmp-pandoc-references",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        performance = {
          debounce = 150,
          throttle = 60,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },             -- R.nvim's r_ls (and marksman) completions
          { name = "pandoc_references" },
          { name = "luasnip", priority = 10 },
          { name = "buffer",  keyword_length = 3 },
          { name = "path" },
        }),
      })
    end,
  },
}
