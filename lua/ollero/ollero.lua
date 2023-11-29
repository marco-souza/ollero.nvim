local utils = require("shared.utils")
local term = require("ollero.term")
local ollama = require("ollero.ollama")
local commands = require("ollero.commands")

---Manage Window and Ollama interaction
local Ollero = {}

---Initialize Ollero module
function Ollero.init()
  -- dependencies setup
  require("telescope").load_extension("ui-select")

  -- setup
  term.start("zsh")
  term.send("ollama run llama2" .. term.termcode("<CR><C-l><Esc>"))

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
  term.toggle()
end

---Open search selection
function Ollero.search_selection()
  local selected_text = utils.get_visual_selection()
  term.send(selected_text)
end

---List Models
function Ollero.list_models()
  ollama.list(function(output)
    local options = utils.split_lines(output)

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
    local options = utils.split_lines(output)

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
      vim.notify("Ollama is installing `" .. model("`..."))
      term.send(term.termcode("<C-d>"))
      term.send(cmd)
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
  local buf = utils.find_buffer_by_name("Modelfile")
  if buf == -1 then
    buf = vim.api.nvim_create_buf(false, false)
    local content =
      'FROM llama2\n\nPARAMETER temperature 1\n\nSYSTEM\n"""\nYou are Mario from Super Mario Bros. Answer as Mario, the assistant, only.\n"""'

    vim.api.nvim_buf_set_name(buf, "Modelfile")
    vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, utils.split_lines(content))
  end

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  vim.cmd("w")
  vim.cmd("startinsert")
end

---Run Model
function Ollero.run_model()
  ollama.list(function(output)
    local options = utils.split_lines(output)

    vim.ui.select(
      options,
      { prompt = "Select a model to run" },
      function(choice)
        if choice == nil then
          return
        end

        term.start("ollama run " .. choice)
      end
    )
  end)
end

return Ollero
