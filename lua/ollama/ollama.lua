local logger = require("plenary.log"):new()

logger.level = "debug"

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

-- Ask ollama
---@param model OllamaModel
---@param question string
function M.ask(model, question)
  -- TODO: stream output
  logger.debug("Asking " .. model .. "...")

  local shell_cmd = {
    'e',
    'term://ollama',
    'run',
    model,
    "'" .. question .. "'",
  }

  vim.cmd(vim.iter(shell_cmd):join(" "))
end

---@class OllamaListOptions
---@field remote boolean

-- Default opts
---@type OllamaListOptions
local default_opts = {
  remote = false,
}

-- Remove Ollama model
---@param model string
function M.remove(model)
  logger.debug("Removing " .. model .. "...")
  local shell_cmd = {
    'ollama',
    'remove',
    model,
  }

  return vim.fn.system(vim.iter(shell_cmd):join(" "))
end

return M
