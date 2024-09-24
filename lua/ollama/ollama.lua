local di = require("di")
local curl = require("plenary.curl")

local logger = di.resolve("logger")

local M = {}

---@alias OllamaModel
---| 'llama2'
---| 'llama3'
---| 'llama3.1'

-- Run Ollama with a given model
---@param model OllamaModel
function M.run(model)
  logger.debug("Running " .. model .. "...")
  local shell_cmd = {
    'term',
    'ollama',
    'run',
    model,
  }

  vim.cmd(vim.iter(shell_cmd):join(" "))
end

---@class OllamaListOptions
---@field remote boolean

-- List Ollama models
---@return OllamaModel[]
function M.fetch_ollama_models()
  vim.print("Listing models...")

  -- WARN:: calling this temporary ollama json API
  local res = curl.get("https://ollama-models.zwz.workers.dev/", { accept = "application/json", })
  local data = vim.json.decode(res.body)
  local models = {}

  for _, model in ipairs(data.models) do
    table.insert(models, model.name)
  end

  return models
end

return M
