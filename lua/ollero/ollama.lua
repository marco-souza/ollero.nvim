local noop = require("shared.utils").noop
local exec = require("shared.utils").exec
local commands = require("ollero.commands")

local Ollama = {}

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
