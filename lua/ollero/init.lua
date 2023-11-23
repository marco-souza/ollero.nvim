Name = "Ollero"

Description = "A plugin to open an input box for chating with Ollama"
local terminal = require("nvterm.terminal")

local win = require("ollero.floating-input")

local WIN_W = 120

local M = {}

local apply_commands = function(mappings)
  for command, handler in pairs(mappings) do
    vim.api.nvim_create_user_command(command, handler, {})
  end
end

local apply_mappings = function(mappings)
  for mapping, handler in pairs(mappings) do
    vim.keymap.set(
      { "n", "v", "i", "t" },
      mapping,
      handler,
      { noremap = true, silent = true }
    )
  end
end

function M.setup()
  -- dependencies setup
  require("telescope").load_extension("ui-select")

  -- setup
  terminal.toggle("vertical")
  terminal.send("ollama run llama2", "vertical")
  terminal.toggle("vertical")

  -- create commands
  apply_commands({
    ["Chat"] = M.openTerm,
    ["Ask"] = M.open,
    ["ListModels"] = M.list_llms,
  })

  -- add keymaps
  apply_mappings({
    ["<M-a>"] = function()
      vim.cmd("Chat")
    end,
    ["<M-s>"] = function()
      vim.cmd("Ask")
    end,
  })
end

function M.open()
  local opts = { prompt = "Ask to 🦙:", width = WIN_W, height = 1 }

  win.input(opts, function(input)
    local close_loading = win.loading_llama(opts)

    require("ollero.ollama").ask_ollama(input, function(output)
      close_loading()

      win.output(
        { prompt = "🦙 said:", width = WIN_W, output = output },
        M.open
      )
    end) -- async
  end)
end

function M.openTerm()
  terminal.toggle("vertical")
end

function M.list_llms()
  local output = require("ollero.ollama").list()
  local options = require("shared.utils").split_lines(output)

  ---@param choice string
  local function on_select(choice)
    -- TODO: do something with this
    vim.notify(choice)
  end

  vim.ui.select(options, { prompt = "List of Ollama Models" }, on_select)
end

return M
