local M = {}


-- Opens original vs result in a new tab with native diff mode.
-- opts.filetype: string — set on both buffers for syntax highlighting
-- opts.on_apply: fn(result_lines) — called when user presses <CR> in result buffer
function M.diff_split(original_lines, result_text, opts)
  opts = opts or {}
  local result_lines = vim.split(vim.trim(result_text), "\n")
  local ft = opts.filetype or "markdown"

  local orig_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(orig_buf, 0, -1, false, original_lines)

  local res_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(res_buf, 0, -1, false, result_lines)

  -- New tab: orig left, result right
  -- Set filetype after each window is active so FileType autocmds fire in the right window context
  vim.cmd("tabnew")
  local orig_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(orig_win, orig_buf)
  vim.bo[orig_buf].filetype = ft
  vim.cmd("diffthis")
  vim.cmd("vsplit")
  local res_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(res_win, res_buf)
  vim.bo[res_buf].filetype = ft
  vim.cmd("diffthis")
  -- Schedule wrap last — runs after diffthis and all FileType autocmds have settled
  vim.schedule(function()
    vim.wo[orig_win].wrap = true
    vim.wo[res_win].wrap = true
  end)

  local function close_tab()
    vim.cmd("diffoff!")
    vim.cmd("tabclose")
  end

  vim.keymap.set("n", "q", close_tab, { buffer = orig_buf, nowait = true })
  vim.keymap.set("n", "q", close_tab, { buffer = res_buf, nowait = true })
  vim.keymap.set("n", "Y", function()
    vim.fn.setreg('"', table.concat(result_lines, "\n"))
    vim.notify("Yanked AI result")
  end, { buffer = res_buf, nowait = true })
  if opts.on_apply then
    vim.keymap.set("n", "<CR>", function()
      opts.on_apply(result_lines)
      close_tab()
    end, { buffer = res_buf, nowait = true })
  end
end

return M
