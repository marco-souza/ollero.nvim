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

function M.exec(shell_cmd, callback)
  local output = vim.fn.system(shell_cmd)
  callback(output)
  return output
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

---get selected linst
---@return string|string[]
function M.get_visual_selection()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local line_start = vstart[2]
  local line_end = vend[2]

  return vim.fn.getline(line_start, line_end)
end

---get selected text
---@param separator string|nil
---@return string
function M.get_selected_text(separator)
  separator = separator or "\n"
  local lines = M.get_visual_selection()

  if type(lines) == "table" then
    return table.concat(lines, separator)
  end

  return lines
end

return M
