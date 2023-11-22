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

function M.split_lines(str)
  local lines = {}
  for s in str:gmatch("[^\r\n]+") do
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

return M
