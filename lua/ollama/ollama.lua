local di = require("di")
local curl = require("plenary.curl")
local Job = require("plenary.job")
local with = require("plenary.context_manager").with
local open = require("plenary.context_manager").open

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

local function is_valid_string(str)
  return str and #str > 0
end

local function generate_modelfile(prompt)
  if not is_valid_string(prompt) then
    logger.debug("Prompt is empty, using default Modelfile")

    local mario_url =
      "https://raw.githubusercontent.com/ollama/ollama/refs/heads/main/examples/modelfile-mario/Modelfile"
    local res = curl.get(mario_url, { accept = "application/text" })
    local modelfile = res.body

    return modelfile
  end

  logger.debug("Prompt is not empty, generating Modelfile using `omg`")

  -- gnerate file using omg
  local modelfile = vim.fn.system("omg " .. prompt)
  return modelfile
end

---Create a new Modelfile with Ollama
---@param prompt string
---@param filename string
---@return any
function M.create_modelfile(prompt, filename)
  prompt = prompt or ""
  prompt = prompt or ""

  logger.debug("Creating Modelfile with prompt: ", prompt)

  local modelfile = generate_modelfile(prompt)

  -- write to a Modelfile
  local filepath = vim.env.PWD .. "/Modelfile"
  if is_valid_string(filename) then
    logger.debug("Filename provided: " .. filename)
    filepath = vim.env.PWD .. "/" .. filename
  end

  logger.debug("Writing Modelfile to " .. filepath)

  with(open(filepath, "w"), function(writer)
    writer:write(modelfile)
  end)

  logger.debug("Modelfile created at " .. filename)

  print("Modelfile created at " .. filepath .. " 🎉")
end

return M
