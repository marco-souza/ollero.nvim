Name = "Ollama Chat"
Description = "A plugin to open an input box for chating with Ollama"

-- local uv = require("luv")
-- local a = require("plenary.async")
local win = require("ollero.floating-input")
local llama = require("ollero.llama")

local WIN_W = 120

local M = {}

function M.open()
  local opts = { prompt = "Ask to 🦙:", width = WIN_W, height = 1 }

  win.input(opts, function(input)
    local close_loading = win.loading_llama(opts)

    llama.ask_llama(input, function(output)
      close_loading()

      win.output(
        { prompt = "🦙 said:", width = WIN_W, output = output },
        M.open
      )
    end) -- async
  end)
end

return M
