local di = require("di")
local curl = require("plenary.curl")
local Job = require("plenary.job")

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
    "term",
    "ollama",
    "run",
    model,
  }

  vim.cmd(vim.iter(shell_cmd):join(" "))
end

-- List Ollama models
---@return OllamaModel[]
function M.fetch_models()
  vim.print("Listing models...")

  -- WARN:: calling this temporary ollama json API
  local url = "https://ollama-models.zwz.workers.dev/"
  local res = curl.get(url, { accept = "application/json" })
  local data = vim.json.decode(res.body)
  local models = {}

  for _, model in ipairs(data.models) do
    table.insert(models, model.name)
  end

  return models
end

-- Install Ollama model
---@param model OllamaModel
---@return any
function M.install(model)
  vim.print("Installing model", model)

  local job = Job:new({
    command = "ollama",
    args = { "pull", model },
    cwd = vim.fn.stdpath("data"),
    on_stderr = function(_, data)
      -- WARN: https://github.com/ollama/ollama/issues/5349
      print(data)
    end,
    on_exit = function(j, code)
      if code == 0 then
        print("Model " .. model .. " installed 🎉")
      else
        print("Failed to install model 😭" .. model)
        logger.error("Failed to install model", j:stderr_result())
      end
    end,
  })

  return job:start()
end

---List installed models
---@return OllamaModel[]
function M.list()
  vim.print("Listing models...")

  local output = vim.fn.system("ollama ls | grep -v NAME | awk '{ print $1 }'")
  local installed_models = vim.split(output, "\n")

  return installed_models
end

-- Remove Ollama model
---@param model OllamaModel
---@return any
function M.remove(model)
  vim.print("Removing model", model)

  local job = Job:new({
    command = "ollama",
    args = { "rm", model },
    cwd = vim.fn.stdpath("data"),
    on_exit = function(j, code)
      if code == 0 then
        print("Model " .. model .. " removed 🎉")
      else
        print("Failed to remove model 😭" .. model)
        logger.error("Failed to remove model", j:stderr_result())
      end
    end,
  })

  return job:start()
end

return M
