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

      -- Patch cmp-pandoc-references: replace get_entries to handle paths with spaces
      -- and fall back to global bib when frontmatter has no bibliography field.
      -- The plugin's locate_bib regex breaks on paths containing spaces.
      local refs = require("cmp-pandoc-references.references")
      local global_bib = "/Users/yangshaojun/Desktop/Workspace/100 Area/110 Academic/111 Literature/zotero.bib"

      local function clean(text)
        if not text then return nil end
        return text:gsub("\n", " "):gsub("%s%s+", " ")
      end

      -- Cache parsed bib entries per file; re-parse only when mtime changes
      local bib_cache = {}

      local function parse_bib(filename, fields)
        local stat = vim.uv.fs_stat(filename)
        local mtime = stat and stat.mtime.sec
        local cached = bib_cache[filename]
        if cached and cached.mtime == mtime then return cached.entries end

        local file = io.open(filename, "rb")
        if not file then return {} end
        local content = file:read("*all")
        file:close()
        local result = {}
        for bibentry in content:gmatch("@.-\n}\n") do
          if not bibentry:match("@[Cc]omment{") then
            local key = bibentry:match("@%w+{(.-),")
            if key then
              local title  = clean(bibentry:match('title%s*=%s*["{]*(.-)["}],?')) or ""
              local author = clean(bibentry:match('author%s*=%s*["{]*(.-)["}],?')) or ""
              local year   = bibentry:match('year%s*=%s*["{]?(%d+)["}]?,?') or ""
              table.insert(result, {
                label = "@" .. key,
                kind  = fields.entry_kind,
                insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
                documentation = {
                  kind  = fields.documentation_kind,
                  value = "**" .. title .. "**\n\n*" .. author .. "*\n" .. year,
                },
              })
            end
          end
        end
        bib_cache[filename] = { mtime = mtime, entries = result }
        return result
      end

      refs.get_entries = function(lines, fields)
        local location = global_bib
        for _, l in ipairs(lines) do
          -- handles spaces in path; strips surrounding quotes
          local loc = l:match("^bibliography%s*:%s*(.+)$")
          if loc then
            loc = loc:gsub('^["\']', ""):gsub('["\']%s*$', ""):gsub("%s+$", "")
            if #loc > 0 then location = loc; break end
          end
        end
        return parse_bib(location, fields)
      end

      -- Prose filetypes: drop buffer noise but keep obsidian wikilink sources
      cmp.setup.filetype({ "markdown", "rmd", "quarto" }, {
        sources = cmp.config.sources({
          { name = "obsidian" },
          { name = "obsidian_new" },
          { name = "obsidian_tags" },
          { name = "pandoc_references" },
          { name = "nvim_lsp" },
          { name = "luasnip", priority = 10 },
          { name = "path" },
        }),
      })
    end,
  },
}
