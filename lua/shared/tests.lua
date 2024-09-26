local M = {}

--- Run a test
---@param name string
---@param cb function
function M.run(name, cb)
  print("Running test: " .. name)
  cb()
  print("Test passed: " .. name)
end

return M
