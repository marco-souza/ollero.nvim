Name = "Ollero"
Description = "A plugin to open an input box for chating with Ollama"
local terminal = require("nvterm.terminal")

-- local uv = require("luv")
-- local a = require("plenary.async")
local win = require("ollero.floating-input")

local WIN_W = 120

local M = {}

function M.setup()
  -- setup
  terminal.toggle("vertical")
  terminal.send("ollama run llama2", "vertical")
  terminal.toggle("vertical")
end

function M.open()
  local opts = { prompt = "Ask to 🦙:", width = WIN_W, height = 1 }

  win.input(opts, function(input)
    local close_loading = win.loading_llama(opts)

    require("ollero.ollama").ask_llama(
      input,
      function(output)
        close_loading()

        win.output(
          { prompt = "🦙 said:", width = WIN_W, output = output },
          M.open
        )
      end
    ) -- async
  end)
end


function M.openTerm()
  terminal.toggle("vertical")
end


function M.list_llms()
  local output = require("ollero.ollama").list()
  -- show llms installed
  win.output(
    { prompt = "🦙 said:", width = WIN_W, output = output },
    function() end
  )
end


return M
