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
  term.start("ollama run llama2")

  commands.apply_commands({
    ["Chat"] = Ollero.chat,
    ["RunModel"] = Ollero.list_models,
    ["ListModels"] = Ollero.list_models,
  })

  commands.apply_mappings({
    ["<M-a>"] = function()
      vim.cmd("Chat")
    end,
    ["<M-s>"] = function()
      Ollero.searchSelection()
    end,
  })
end

---Open chat
function Ollero.chat(input)
  P(input)
  term.toggle()
end

---Open search selection
function Ollero.searchSelection()
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

return Ollero
