local M = {}

-- setup resolution path
package.path = package.path .. ";./lua/?.lua"

local log = require("shared.logger").create_logger({ log_level = "debug" })

--- Run a test
---@param name string
---@param cb function
function M.run(name, cb)
  log.debug("Running test: " .. name)
  cb()
  log.debug("Test passed: " .. name)
end

---Check if a file is a test file
---@param file string
---@return boolean
local function is_test_file(file)
  return file:match(".*_test.lua$")
end

--- Find and run all tests
function M.test()
  local files = vim.fs.find(
    is_test_file,
    { type = "file", path = vim.fn.getcwd() .. "/lua", limit = math.huge }
  )

  for _, file in ipairs(files) do
    local relative_path = file:gsub(".*/ollero.nvim/lua/", "")
    local require_path = relative_path:gsub(".lua", ""):gsub("/", ".")

    require(require_path)
    print(".")
  end
  print("\n")
end

return M
