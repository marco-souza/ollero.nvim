local utils = require("shared.utils")
local Term = require("term.term")
local ollama = require("ollero.ollama")
local commands = require("ollero.commands")

local term = Term:new({ title = "👁️🦙 Ask Ollero ",
})

---Manage Window and Ollama interaction
local Ollero = {}

---Initialize Ollero module
function Ollero.init(opts)
  -- dependencies setup
  require("telescope").load_extension("ui-select")

  local model = opts.model or "llama3";

  -- setup
  ollama.init(function()
    ollama.run(model, function(cmd)
      term:start("zsh") -- init terminal
      term:send(cmd .. term:termcode("<CR><C-l><Esc>"))
    end)
  end)

  commands.apply_commands({
    ["Chat"] = Ollero.chat,
    ["RunModel"] = Ollero.run_model,
    ["ListModels"] = Ollero.list_models,
    ["RemoveModel"] = Ollero.remove_model,
    ["BuildModel"] = Ollero.build_model,
    ["CreateModel"] = Ollero.create_model,
    ["InstallModel"] = Ollero.install_model,
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

---Open search selection
function Ollero.search_selection()
  -- FIXME: make v select work
  local selected_text = utils.get_visual_selection()
  term:send(selected_text)
end

---List Models
function Ollero.list_models()
  ollama.list(function(output)
    local options = utils.split(output)

    ---@param choice string
    local function on_select(choice)
      vim.notify("Selected model: " .. choice)
    end

    vim.ui.select(options, { prompt = "List of Ollama Models" }, on_select)
  end)
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
  ---@param model string
  local function on_select(model)
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
  end

  ollama.list_remote(function(options)
    vim.ui.select(options, { prompt = "🗂️ Install a model" }, on_select)
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
      args = { 'generate', input },
      on_exit = function(j, exit_code)
        local content = table.concat(j:result(), "\n")

        if exit_code ~= 0 then
          print("Error!", content)
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
