local di = require("di")
local curl = require("plenary.curl")
local Job = require("plenary.job")
local with = require("plenary.context_manager").with
local open = require("plenary.context_manager").open
local strings = require("shared.strings")

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
  local response_models = vim.json.decode(res.body)
  local models = {}

  for _, model in ipairs(response_models) do
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

local function generate_modelfile(prompt)
  if not strings.is_valid(prompt) then
    logger.debug("Prompt is empty, using default Modelfile")

    local mario_url =
      "https://raw.githubusercontent.com/ollama/ollama/refs/heads/main/examples/modelfile-mario/Modelfile"
    local res = curl.get(mario_url, { accept = "application/text" })
    local modelfile = res.body

    return modelfile
  end

  logger.debug("Prompt is not empty, generating Modelfile using `omg`")

  -- gnerate file using omg
  local modelfile = vim.fn.system("omg '" .. prompt .. "'")
  return modelfile
end

local function get_modelfile_path(filename)
  filename = filename or ""
  if not strings.is_valid(filename) then
    filename = "Modelfile"
  end

  local filepath = vim.fs.joinpath(vim.env.PWD, filename)
  return filepath
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

  local filepath = get_modelfile_path(filename)
  logger.debug("Writing Modelfile to " .. filepath)

  -- write to a Modelfile
  with(open(filepath, "w"), function(writer)
    writer:write(modelfile)
  end)

  logger.debug("Modelfile created at " .. filename)

  print("Modelfile created at " .. filepath .. " 🎉")
end

---Build a model with Ollama
---@param name string
---@param filename string
---@return any
function M.build_model(name, filename)
  if not strings.is_valid(name or "") then
    logger.error("Model name is empty")
    return
  end

  local filepath = get_modelfile_path(filename)

  print("Building model " .. name .. " with " .. filepath)

  local job = Job:new({
    command = "ollama",
    args = { "create", "-f", filepath, name },
    cwd = vim.fn.stdpath("data"),
    on_exit = function(j, code)
      if code == 0 then
        print("Model " .. name .. " built 🎉")
      else
        print("Failed to build model 😭" .. name)
        logger.error("Failed to build model", j:stderr_result())
      end
    end,
  })

  return job:start()
end

return M
