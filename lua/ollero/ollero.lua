local di = require("di")
local strings = require("shared.strings")
local commands = require("shared.commands")

local term = di.resolve("term")
local logger = di.resolve("logger")
local ollama = di.resolve("ollama")

---Manage Window and Ollama interaction
local Ollero = {}

---Initialize Ollero module
function Ollero.init(opts)
  -- dependencies setup
  require("telescope").load_extension("ui-select")

  local model = opts.model or "llama3.2"

  -- setup
  term.win:show()
  ollama.run(model)
  term.win:hide()

  commands.apply_commands({
    ["Chat"] = Ollero.chat,
    ["RunModel"] = Ollero.run_model,
    ["ListModels"] = Ollero.list_models,
    ["RemoveModel"] = Ollero.remove_model,
    ["BuildModel"] = Ollero.build_model,
    ["CreateModel"] = Ollero.create_model,
    ["InstallModel"] = Ollero.install_model,
    ["Ask"] = Ollero.ask,
  }, {
    BuildModel = { nargs = "*" },
    CreateModel = { nargs = "*" },
    Ask = { nargs = "*" },
  })

  commands.apply_mappings({
    ["<M-a>"] = function()
      vim.cmd("Chat")
    end,
    ["<M-s>"] = function()
      Ollero.search_selection()
    end,
  })
end

---Open chat
function Ollero.chat()
  term.win:toggle()
end

-- Ask to open gpt chat
function Ollero.ask(opts)
  logger.debug("Asking question: ", opts)

  local question = opts.args
  if question == nil then
    logger.error("No question provided")
    return
  end

  term:send(question)
  term.win:toggle()
end

---List Models
function Ollero.list_models()
  local options = ollama.list()
  local online_options = ollama.fetch_models()

  options[#options] = "-----------------"

  for _, model in ipairs(online_options) do
    if strings.is_valid(model) then
      table.insert(options, model .. " (remote)")
    end
  end

  ---@param choice string
  local function on_select(choice)
    vim.notify("Selected model: " .. choice)

    term.win:show()
    term:send(term:termcode("<C-d>")) -- stop
    ollama.run(choice) -- kickoff new model
  end

  vim.ui.select(options, { prompt = "List of Ollama Models" }, on_select)
end

---List Models
function Ollero.install_model()
  local options = ollama.fetch_models()

  vim.ui.select(
    options,
    { prompt = "📦 Select an Ollama Model to install" },
    function(choice)
      vim.notify("Installing model: " .. choice)
      ollama.install(choice)
    end
  )
end

---Remove Model
function Ollero.remove_model()
  local options = ollama.list()

  vim.ui.select(
    options,
    { prompt = "🗑️ Select an Ollama Model to remove" },
    function(choice)
      vim.notify("Removing model: " .. choice)
      ollama.remove(choice)
      vim.notify("Model " .. choice .. " removed")
    end
  )
end

---Build Model
function Ollero.build_model(opts)
  local filename = opts.args or "Modelfile"

  vim.ui.input({ prompt = "Enter model name: " }, function(name)
    vim.schedule(function()
      ollama.build_model(name, filename)
    end)
  end)
end

---Create Model
function Ollero.create_model(opts)
  vim.ui.input({
    prompt = "Enter a prompt to generate your file (enter to skip): ",
  }, function(prompt)
    vim.schedule(function()
      ollama.create_modelfile(prompt, opts.args)
    end)
  end)
end

return Ollero
