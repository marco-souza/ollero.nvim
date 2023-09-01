local a = require("plenary.async")
local utils = require("shared.utils")

local M = {}

function M.window_center(width, height)
  return {
    relative = "win",
    row = vim.api.nvim_win_get_height(0) / 2 - height / 2,
    col = vim.api.nvim_win_get_width(0) / 2 - width / 2,
  }
end

function M._win_config(opts)
  local prompt = opts.prompt or "Input: "
  local win_config = {}

  -- Calculate a minimal width with a bit buffer
  local width = opts.width
  if not width or width + 20 > vim.api.nvim_win_get_width(0) then
    width = vim.api.nvim_win_get_width(0) - 20
    if width < 0 then
      width = 1
    end
  end

  -- Calculate a minimal height with a bit buffer
  local height = opts.height
  if not height or height + 20 > vim.api.nvim_win_get_height(0) then
    height = vim.api.nvim_win_get_height(0) - 20
    if height < 0 then
      height = 1
    end
  end

  local default_win_config = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    width = width,
    height = height,
    title = prompt,
  }

  default_win_config = vim.tbl_deep_extend(
    "force",
    default_win_config,
    M.window_center(width, height)
  )

  -- Apply user's window config.
  win_config = vim.tbl_deep_extend("force", default_win_config, win_config)
  return win_config
end

function M.create_win(opts, output)
  local win_config = M._win_config(opts)
  local buffer = vim.api.nvim_create_buf(false, true)
  local window = vim.api.nvim_open_win(buffer, true, win_config)

  output = output or { opts.default }

  vim.api.nvim_buf_set_lines(buffer, 0, 0, 0, output)

  -- Enter, Esc or q to close
  local cleanup = function()
    vim.api.nvim_win_close(window, true)
    vim.api.nvim_buf_delete(buffer, { force = true })
  end

  vim.keymap.set("n", "<esc>", cleanup, { buffer = buffer })
  vim.keymap.set("n", "q", cleanup, { buffer = buffer })

  return window, buffer, cleanup
end

function M.output(opts, on_enter)
  local output = utils.split_lines(opts.output or { "" })
  local _, b, cleanup = M.create_win(opts, output)

  -- vim.keymap.set({ 'n', 'i', 'v' }, '<cr>', M.input({), { buffer = buffer })
  vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
    cleanup()
    if on_enter then
      on_enter()
    end
  end, { buffer = b })
end

function M.loading_llama(opts, rx)
  local loading_text = "🦙 loading"
  local w, _, cleanup = M.create_win(opts, { loading_text })

  vim.api.nvim_win_set_cursor(w, { 1, vim.str_utfindex(loading_text) + 1 })

  return cleanup
end

function M.input(opts, on_enter)
  local default = opts.default or ""
  local w, b, close = M.create_win(opts, { default })

  -- Put cursor at the end of the default value
  vim.cmd("startinsert")
  vim.api.nvim_win_set_cursor(w, { 1, vim.str_utfindex(default) + 1 })

  -- Enter to confirm
  vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
    vim.cmd("stopinsert")

    local lines = vim.api.nvim_buf_get_lines(b, 0, 1, false)
    local input = lines[1]

    close()

    if on_enter then
      on_enter(input)
    end
  end, { buffer = b })
end

return M
