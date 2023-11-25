local terminal = require("nvterm.terminal")
local utils = require("shared.utils")
local ollama = require("ollero.ollama")
local commands = require("ollero.commands")

---Manage Window and Ollama interaction
local Ollero = {}

---Initialize Ollero module
function Ollero.init()
  -- dependencies setup
  require("telescope").load_extension("ui-select")

  -- setup
  terminal.toggle("vertical")
  terminal.send("ollama run llama2", "vertical")
  terminal.toggle("vertical")

  commands.apply_commands({
    ["Chat"] = Ollero.chat,
    ["CreateModel"] = Ollero.list_models,
    ["ListModels"] = Ollero.list_models,
  })

  commands.apply_mappings({
    ["<M-a>"] = function()
      vim.cmd("Chat")
    end,
  })
end

---Open chat
function Ollero.chat()
  terminal.toggle("vertical")
end

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
