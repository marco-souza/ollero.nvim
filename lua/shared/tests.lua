local M = {}

-- setup resolution path
package.path = package.path .. ";./lua/?.lua"

--- Run a test
---@param name string
---@param cb function
function M.run(name, cb)
  print(string.format("Running test: %s", name))
  cb()
  print(string.format("Test passed: %s", name))
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
