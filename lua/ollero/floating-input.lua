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
  end

  -- Calculate a minimal height with a bit buffer
  local height = opts.height
  if not height or height + 20 > vim.api.nvim_win_get_height(0) then
    height = vim.api.nvim_win_get_height(0) - 20
  end

  local default_win_config = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    width = width,
    height = height,
    title = prompt,
  }

  default_win_config = vim.tbl_deep_extend("force", default_win_config, M.window_center(width, height))

  -- Apply user's window config.
  win_config = vim.tbl_deep_extend("force", default_win_config, win_config)
  return win_config
end

function M.output(opts, on_close)
  local output = utils.split_lines(opts.output or { "" })
  local win_config = M._win_config(opts)

  local buffer = vim.api.nvim_create_buf(false, true)
  local window = vim.api.nvim_open_win(buffer, true, win_config)
  vim.api.nvim_buf_set_lines(buffer,0, 0, true, output)

  -- Enter, Esc or q to close
  local close_win = function(keep_win)
    return function ()
      vim.api.nvim_win_close(window, true)

      if not keep_win and on_close then
        on_close()
      end
    end
  end

  -- vim.keymap.set({ 'n', 'i', 'v' }, '<cr>', M.input({), { buffer = buffer })
  vim.keymap.set({ 'n', 'i', 'v' }, '<cr>', close_win(false), { buffer = buffer })
  vim.keymap.set("n", "<esc>", close_win, { buffer = buffer })
  vim.keymap.set("n", "q", close_win, { buffer = buffer })
end

local loading_llama = function(window)
  local loading_text = "🦙 loading";
  local buffer = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_text(buffer, 0, 0, 0, 0, { loading_text })
  vim.api.nvim_win_set_buf(window, buffer)
  vim.api.nvim_win_set_cursor(window, { 1, vim.str_utfindex(loading_text) + 1  })

  return buffer
end

function M.input(opts, on_confirm)
  local default = opts.default or ""
  local win_config = M._win_config(opts)

  -- Create floating window.
  local buffer = vim.api.nvim_create_buf(false, true)
  local window = vim.api.nvim_open_win(buffer, true, win_config)
  vim.api.nvim_buf_set_text(buffer, 0, 0, 0, 0, { default })

  -- Put cursor at the end of the default value
  vim.cmd('startinsert')
  vim.api.nvim_win_set_cursor(window, { 1, vim.str_utfindex(default) + 1 })

  -- Enter to confirm
  vim.keymap.set({ 'n', 'i', 'v' }, '<cr>', function()
    loading_llama(window)

    local lines = vim.api.nvim_buf_get_lines(buffer, 0, 1, false)
    if lines[1] ~= default then
      local input = lines[1]
      vim.cmd('stopinsert')
      vim.api.nvim_win_close(window, true)

      if on_confirm then
        on_confirm(input)
      end
    end
  end, { buffer = buffer })

  -- Esc or q to close
  vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(window, true) end, { buffer = buffer })
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(window, true) end, { buffer = buffer })
end

return M
