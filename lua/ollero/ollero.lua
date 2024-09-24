local utils     = require("shared.utils")
local di        = require("di")
local ollama    = require("ollero.ollama")
local commands  = require("ollero.commands")
local curl      = require("plenary.curl")

local term      = di.resolve("term")
local logger    = di.resolve("logger")
local ollama_v2 = di.resolve("ollama")

---Manage Window and Ollama interaction
local Ollero    = {}

---Initialize Ollero module
function Ollero.init(opts)
  -- dependencies setup
  require("telescope").load_extension("ui-select")

  local model = opts.model or "llama3.1";

  -- setup
  term.win:show()
  ollama_v2.run(model)
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
    Ask = { nargs = '*' }
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
  -- term:send(term:termcode("<C-d>"))
  -- di.resolve("ollama").ask(model, question)
end

---List Models
function Ollero.list_models()
  local options = ollama_v2.fetch_ollama_models()

  ---@param choice string
  local function on_select(choice)
    vim.notify("Selected model: " .. choice)
    term.win:show()
    term:send(term:termcode("<C-d>")) -- stop
    di.resolve("ollama").run(choice)  -- kickoff new model
  end

  vim.ui.select(options, { prompt = "List of Ollama Models" }, on_select)
end

---Remove Model
function Ollero.remove_model()
  ollama.list(function(output)
    local options = utils.split(output)

    ---@param model string
    local function on_select(model)
      if model == nil then
        return
      end

      vim.notify("Removing " .. model .. "...")

      ollama.rm(model, function()
        vim.notify(model .. " removed!")
      end)
    end

    vim.ui.select(
      options,
      { prompt = "🗑️ Select a model to removed" },
      on_select
    )
  end)
end

---Install Model
function Ollero.install_model()
  local options = ollama_v2.fetch_ollama_models()

  vim.ui.select(options, { prompt = "🗂️ Install a model" }, function(model)
    if model == nil then
      return
    end

    ollama.install(model, function(cmd)
      vim.notify("Ollama is installing `" .. model .. "`...")
      term:send(term:termcode("<C-d>"))
      term:send(cmd)

      ollama.run(model, function(install_cmd)
        term:send(install_cmd)
        term:send(term:termcode("<C-l>"))
      end)
    end)
  end)
end

---Build Model
function Ollero.build_model()
  vim.ui.input({ prompt = "Enter model name: " }, function(input)
    ollama.build_model(input, function()
      vim.notify("Model " .. input .. " created")
    end)
  end)
end

---Create Model
function Ollero.create_model()
  local filename = "Modelfile"
  vim.ui.input({ prompt = "Enter model name: " }, function(input)
    local job = require('plenary.job')

    local omg_job = job:new({
      command = 'omg',
      args = { input },
      on_exit = function(j, exit_code)
        local content = table.concat(j:result(), "\n")

        if exit_code ~= 0 then
          logger.error("Error!", content)
          return nil
        end

        -- write to Modelfile
        local with = require('plenary.context_manager').with
        local open = require('plenary.context_manager').open

        with(open(filename, "w"), function(writer)
          writer:write(content)
        end)

        vim.schedule(function()
          -- dispatch to main thread
          vim.cmd("e Modelfile")
        end)
      end,
    })

    omg_job:start()
  end)
end

---Run Model
function Ollero.run_model()
  ollama.list(function(output)
    local options = utils.split(output)

    vim.ui.select(
      options,
      { prompt = "Select a model to run" },
      function(choice)
        if choice == nil then
          return
        end

        ollama.run(choice, function(cmd)
          term:send(term:termcode("<C-d>"))
          term:send(cmd)
          term:send(term:termcode("<C-l>"))
        end)
      end
    )
  end)
end

return Ollero
