P = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(...)
  return require("plenary.reload").reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end

local M = {}

function M.split(str, sep)
  local lines = {}
  sep = sep or "\n"

  for s in str:gmatch("[^\r" .. sep .. "]+") do
    table.insert(lines, s)
  end

  return lines
end

function M.noop() end

function M.exec(shellCmd, callback)
  local handler = io.popen(shellCmd)
  if not handler then
    return error("Cannot execute shell command")
  end

  local output = handler:read("*a")
  handler:close()

  callback(output)

  return output
end

function M.get_visual_selection()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local line_start = vstart[2]
  local line_end = vend[2]

  -- or use api.nvim_buf_get_lines
  local lines = vim.api.nvim_buf_get_lines(
    vim.api.nvim_get_current_buf(),
    line_start,
    line_end,
    false
  )

  return table.concat(lines, "\n")
end

---find buf by buf name
---@param name string
---@return number
M.find_buffer_by_name = function(name)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name == name then
      return buf
    end
  end
  return -1
end

return M
