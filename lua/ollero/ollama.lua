local noop = require("shared.utils").noop
local exec = require("shared.utils").exec

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
function Ollama.list(callback)
  local sh_script =
    "ollama ls | grep : | awk '{ print $1 }' | awk -F ':' '{ print $1 }' "
  return exec(sh_script, callback or noop)
end

---@param model string
---@param callback function(input string) | nil
function Ollama.install(model, callback)
  vim.notify("Installing " .. model .. "...")
  local sh_script = "ollama pull " .. model
  local cb = (callback or noop)
  return cb(sh_script)
end

---@param model string
---@param callback function(input string) | nil
function Ollama.run(model, callback)
  vim.notify("Running " .. model .. "...")
  local sh_script = "ollama run " .. model
  local cb = (callback or noop)
  return cb(sh_script)
end

---@param model string
---@param callback function | nil
function Ollama.rm(model, callback)
  local sh_script = "ollama rm " .. model
  return exec(sh_script, callback or noop)
end

---@param filepath string
---@param callback function
function Ollama.create_model(filepath, callback)
  -- local sh_script = "ollama ls | grep : | awk '{ printf \"%sv;%s;%s %s;%s %s %s\\n\", $1, $2, $3, $4, $5, $6, $7 }'"
  local sh_script = "ollama create " .. filepath
  return exec(sh_script, callback or noop)
end

---@param model_name string
---@param callback function
function Ollama.build_model(model_name, callback)
  local sh_script = "ollama create -f Modelfile " .. model_name
  return exec(sh_script, callback or noop)
end

return Ollama
