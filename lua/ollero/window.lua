local M = {}

local function build_default_config(opts)
  local prompt = opts.prompt or "Input: "

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

  return {
    focusable = true,
    style = "minimal",
    border = "rounded",
    width = width,
    height = height,
    title = prompt,
  }
end

local function window_center(width, height)
  return {
    relative = "win",
    row = vim.api.nvim_win_get_height(0) / 2 - height / 2,
    col = vim.api.nvim_win_get_width(0) / 2 - width / 2,
  }
end

function M.win_config(opts)
  local config = build_default_config(opts)

  -- Apply user's window config.
  config = vim.tbl_deep_extend(
    "force",
    config,
    window_center(config.width, config.height)
  )

  return config
end

return M
