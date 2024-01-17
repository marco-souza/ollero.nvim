local noop = require("shared.utils").noop
local exec = require("shared.utils").exec

-- run with docker
local ollama_cmd = "docker exec -it ollama ollama"
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
  local ollama_init = [[
  [ "$(docker ps | grep ollama)" = "" ] && ( \
      docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama || \
      docker restart ollama \
    )
  ]]
  return exec(ollama_init, callback or noop)
end

---@param callback function | nil
function Ollama.list(callback)
  local sh_script = ollama_cmd .. " ls | grep : | " .. "awk '{ print $1 }'"
  return exec(sh_script, callback or noop)
end

---@param model string
---@param callback function(input string) | nil
function Ollama.install(model, callback)
  vim.notify("Installing " .. model .. "...")
  local sh_script = ollama_cmd .. " pull " .. model
  local cb = (callback or noop)
  return cb(sh_script)
end

---@param model string
---@param callback function(input string) | nil
function Ollama.run(model, callback)
  vim.notify("Running " .. model .. "...")
  local sh_script = ollama_cmd .. " run " .. model
  local cb = (callback or noop)
  return cb(sh_script)
end

---@param model string
---@param callback function | nil
function Ollama.rm(model, callback)
  local sh_script = ollama_cmd .. " rm " .. model
  return exec(sh_script, callback or noop)
end

---@param filepath string
---@param callback function
function Ollama.create_model(filepath, callback)
  -- local sh_script = ollama_cmd .. " ls | grep : | awk '{ printf \"%sv;%s;%s %s;%s %s %s\\n\", $1, $2, $3, $4, $5, $6, $7 }'"
  local sh_script = ollama_cmd .. " create " .. filepath
  return exec(sh_script, callback or noop)
end

---@param model_name string
---@param callback function
function Ollama.build_model(model_name, callback)
  local sh_script = ollama_cmd .. " create -f Modelfile " .. model_name
  return exec(sh_script, callback or noop)
end

return Ollama
