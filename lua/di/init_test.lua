--- create test in lua
local di = require("lua.di")

--- Run a test
---@param name string
---@param cb function
local function run(name, cb)
  print("Running test: " .. name)
  cb()
  print("Test passed: " .. name)
end

run("test module setup", function()
  assert(di.Name == "Dependency Injection", "Name is incorrect")
  assert(
    di.Description == "Dependency Injection in Lua",
    "Description is incorrect"
  )
end)

run("test register and resolving a simple value", function()
  di.register({ name = "test", value = "test" })
  assert(di.resolve("test") == "test", "Value is incorrect")
end)

run("test register and resolving a factory function", function()
  di.register({
    name = "test",
    value = function()
      return "test"
    end,
  })
  assert(di.resolve("test") == "test", "Value is incorrect")
end)
