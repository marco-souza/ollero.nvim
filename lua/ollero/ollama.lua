local noop = require("shared.utils").noop
local exec = require("shared.utils").exec

local Ollama = {}

---@param callback function | nil
function Ollama.list(callback)
  local sh_script =
    "ollama ls | grep : | awk '{ print $1 }' | awk -F ':' '{ print $1 }' "
  return exec(sh_script, callback or noop)
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

return Ollama
