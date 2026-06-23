-- Vault task picker (<leader>ot) + project board (<leader>op)
-- + date-insertion keymaps (<leader>td / <leader>ts / <leader>ta)
-- + task toggle (<leader>tc): [ ] → [x] ✅ date, [x] → [ ] strips ✅ date

local STATUS_ICON = { active = "󰐊", recurring = "󰑖", ["on-hold"] = "󰏤", ["to-start"] = "󰄱", done = "󰗠" }
local STATUS_ORDER = { active = 0, recurring = 1, ["to-start"] = 2, ["on-hold"] = 3, done = 4 }

local function open_project_picker()
  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local raw = vim.fn.systemlist("vault-projects 2>/dev/null")
  if vim.v.shell_error ~= 0 and #raw == 0 then
    vim.notify("vault-projects: not found or errored — is it in PATH?", vim.log.levels.ERROR)
    return
  end

  local results = {}
  for _, line in ipairs(raw) do
    local parts = vim.split(line, "\t", { plain = true })
    if #parts >= 4 then
      local status   = parts[1]
      local priority = parts[2]
      local file     = parts[3]
      local title    = parts[4]
      local desc     = parts[5] or ""
      local tags     = parts[6] or ""
      local icon     = STATUS_ICON[status] or "·"
      local stars    = (priority ~= "0" and priority ~= "") and ("★" .. priority .. " ") or "   "
      table.insert(results, {
        status   = status, priority = priority, file = file,
        title = title, desc = desc, tags = tags,
        display = string.format("%s %-10s %s%-28s %s", icon, status, stars, title, desc),
        ordinal = status .. " " .. priority .. " " .. title .. " " .. desc .. " " .. tags,
      })
    end
  end

  table.sort(results, function(a, b)
    local oa = STATUS_ORDER[a.status] or 9
    local ob = STATUS_ORDER[b.status] or 9
    if oa ~= ob then return oa < ob end
    return (tonumber(b.priority) or 0) > (tonumber(a.priority) or 0)
  end)

  local active = 0
  for _, r in ipairs(results) do if r.status == "active" or r.status == "recurring" then active = active + 1 end end

  pickers.new({}, {
    prompt_title = string.format("Projects  ● %d active  · %d total", active, #results),
    finder = finders.new_table({
      results = results,
      entry_maker = function(e)
        return { value = e, display = e.display, ordinal = e.ordinal, filename = e.file, lnum = 1 }
      end,
    }),
    sorter    = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local sel = action_state.get_selected_entry()
        if sel then vim.cmd({ cmd = "edit", args = { sel.filename } }) end
      end)
      return true
    end,
  }):find()
end

local function open_task_picker()
  local pickers     = require("telescope.pickers")
  local finders     = require("telescope.finders")
  local conf        = require("telescope.config").values
  local actions     = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local raw = vim.fn.systemlist("vault-tasks 2>/dev/null")
  if vim.v.shell_error ~= 0 and #raw == 0 then
    vim.notify("vault-tasks: not found or errored — is it in PATH?", vim.log.levels.ERROR)
    return
  end

  local results     = {}
  local must_count  = 0
  for _, line in ipairs(raw) do
    local parts = vim.split(line, "\t", { plain = true })
    if #parts >= 4 then
      local section = parts[1]
      local file    = parts[2]
      local lnum    = tonumber(parts[3])
      local text    = parts[4]
      if section == "MUST" then must_count = must_count + 1 end
      table.insert(results, {
        section  = section,
        file     = file,
        lnum     = lnum,
        text     = text,
        display  = (section == "MUST" and "🔥 " or "   ") .. text,
        -- ordinal: MUST sorts before TODO alphabetically
        ordinal  = section .. " " .. text,
      })
    end
  end

  local todo_count = #results - must_count
  local title = string.format("Vault Tasks  🔥 %d urgent  · %d to do", must_count, todo_count)

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value    = entry,
          display  = entry.display,
          ordinal  = entry.ordinal,
          filename = entry.file,
          lnum     = entry.lnum,
        }
      end,
    }),
    sorter    = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local sel = action_state.get_selected_entry()
        if sel then
          vim.cmd({ cmd = "edit", args = { sel.filename } })
          vim.api.nvim_win_set_cursor(0, { sel.lnum, 0 })
          vim.cmd("normal! zz")
        end
      end)
      return true
    end,
  }):find()
end

local function toggle_task()
  local row  = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if line:match("%- %[x%]") then
    line = line:gsub("%- %[x%]", "- [ ]", 1)
    line = line:gsub("%s*✅%s*%d%d%d%d%-%d%d%-%d%d", "")
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line })
  elseif line:match("%- %[ %]") then
    local completed = line:gsub("%- %[ %]", "- [x]", 1) .. " ✅ " .. os.date("%Y-%m-%d")
    if line:match("🔁") then
      local next_lines = vim.fn.systemlist("vault-task-recur", { line })
      if vim.v.shell_error == 0 and #next_lines > 0 then
        -- new recurring instance above, completed below (matches Obsidian behaviour)
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { next_lines[1], completed })
        return
      end
    end
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { completed })
  end
end

local function append_date(emoji)
  vim.ui.input(
    { prompt = emoji .. " date (YYYY-MM-DD, Enter = today): " },
    function(input)
      if input == nil then return end
      local d = (input == "") and os.date("%Y-%m-%d") or input
      if not d:match("^%d%d%d%d%-%d%d%-%d%d$") then
        vim.notify("Invalid date — use YYYY-MM-DD", vim.log.levels.WARN)
        return
      end
      local row  = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
      vim.api.nvim_buf_set_lines(0, row - 1, row, false,
        { line .. " " .. emoji .. " " .. d })
    end
  )
end

return {
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    init = function()
      -- Markdown-only: append due / scheduled date to the current task line
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = "markdown",
        group    = vim.api.nvim_create_augroup("VaultTaskDates", { clear = true }),
        callback = function(ev)
          vim.keymap.set("n", "<leader>td", function() append_date("📅") end,
            { buffer = ev.buf, desc = "Set due date on task" })
          vim.keymap.set("n", "<leader>ts", function() append_date("⏳") end,
            { buffer = ev.buf, desc = "Set scheduled date on task" })
          vim.keymap.set("n", "<leader>ta", function() append_date("🛫") end,
            { buffer = ev.buf, desc = "Set start date on task" })
          vim.keymap.set("n", "<leader>tx", toggle_task,
            { buffer = ev.buf, desc = "Toggle task done (✅ date)" })
        end,
      })
    end,
    keys = {
      { "<leader>ot", open_task_picker,    desc = "Vault tasks" },
      { "<leader>op", open_project_picker, desc = "Vault projects" },
    },
  },
}
