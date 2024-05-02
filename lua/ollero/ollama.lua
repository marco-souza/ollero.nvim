local noop = require("shared.utils").noop
local exec = require("shared.utils").exec
local commands = require("ollero.commands")

local Ollama = {}

---@param callback function(options: string) | nil
function Ollama.list_remote(callback)
  -- TODO: load this from https://ollama.ai/library
  local options = {
    "llama2",
    "mistral",
    "orca-mini",
    "codellama",
    "llama2-uncensored",
    "vicuna",
    "wizard-vicuna-uncensored",
  }
  local cb = callback or noop
  return cb(options)
end

---@param callback function | nil
function Ollama.init(callback)
  -- TODO: ensure ollama is installed
  local cb = callback or noop
  return cb()
  -- local ollama_init = [[
  -- [ "$(docker ps | grep ollama)" = "" ] && ( \
  --     docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama || \
  --     docker restart ollama \
  --   )
  -- ]]
  -- return exec(ollama_init, callback or noop)
end

---@param callback function | nil
function Ollama.list(callback)
  local shell_cmd = commands.CommandBuilder
      :new()
      :run("ollama ls | grep : | awk '{ print $1 }'")
      :build()
  return exec(shell_cmd, callback or noop)
end

---@param model string
---@param callback function(input string) | nil
function Ollama.install(model, callback)
  vim.notify("Installing " .. model .. "...")
  local shell_cmd =
      commands.CommandBuilder:new():run("ollama pull " .. model):build()
  local cb = (callback or noop)
  return cb(shell_cmd)
end

---@param model string
---@param callback function(input string) | nil
function Ollama.run(model, callback)
  vim.notify("Running " .. model .. "...")
  local shell_cmd = commands.CommandBuilder
      :new()
      :run("ollama run " .. model)
      :build()
  local cb = (callback or noop)
  return cb(shell_cmd)
end

---@param model string
---@param callback function | nil
function Ollama.rm(model, callback)
  local shell_cmd =
      commands.CommandBuilder:new():run("ollama rm " .. model):build()
  return exec(shell_cmd, callback or noop)
end

---@param filepath string
---@param callback function
function Ollama.create_model(filepath, callback)
  local shell_cmd =
      commands.CommandBuilder:new():run("ollama create " .. filepath):build()
  return exec(shell_cmd, callback or noop)
end

---@param model_name string
---@param callback function
function Ollama.build_model(model_name, callback)
  local shell_cmd = commands.CommandBuilder
      :new()
      :run("ollama create -f Modelfile " .. model_name)
      :build()
  return exec(shell_cmd, callback or noop)
end

return Ollama
