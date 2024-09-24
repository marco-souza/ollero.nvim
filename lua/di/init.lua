local M = {}

M.Name = "Dependency Injection"
M.Description = "Dependency Injection in Lua"

-- Features a Dependency Injection system needs to have
-- - register a Dependency
-- - resolve a Dependency, with values or factory functions

local dependencies = {}

---@class RegisterOptions
---@field name string
---@field value function | any

---@param opts RegisterOptions
---@return nil
M.register = function(opts)
  opts = opts or {}
  if not opts.name then
    error("Name is required")
  end

  if not opts.value then
    error("Value is required")
  end

  local name = opts.name
  local value = opts.value

  if dependencies[name] then
    return
  end

  dependencies[name] = value
end

-- Get a registered dependency
---@param name string
---@return any
M.resolve = function(name)
  if not dependencies[name] then
    error("Dependency not found: " .. name)
  end

  local value = dependencies[name]

  if type(value) == "function" then
    local val = value()
    dependencies[name] = val
    return val
  end

  return value
end

return M
