local noop = require("shared.utils").noop
local exec = require("shared.utils").exec

local Ollama = {}

---@param callback function | nil
function Ollama.list(callback)
  -- local sh_script = "ollama ls | grep : | awk '{ printf \"%sv;%s;%s %s;%s %s %s\\n\", $1, $2, $3, $4, $5, $6, $7 }'"
  local sh_script = "ollama ls | grep : | awk '{ printf \"%s\\n\", $1 }'"
  -- local sh_script = "ollama ls | grep :"
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
