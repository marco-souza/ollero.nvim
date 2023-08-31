Name = "Ollama Chat"
Description = "A plugin to open an input box for chating with Ollama"

local win = require("ollero.floating-input")

local WIN_W = 120

local M = {}

function M.setup(opts)
    print("Hello from ollero!")
end

function M.open()
  -- Display the input box
  win.input(
    { prompt = "Ask to 🦙:", width = WIN_W },
    function (input)
      local shellCmd = "echo '" .. input .. "' | ollama run llama2"
      local handler = io.popen(shellCmd)

      if not handler then
          return error("Cannot execute shell command")
      end

      local output = handler:read("*a")
      handler:close()

     win.output({ prompt = "🦙 said:", width = WIN_W , output = output }, M.open)
    end
  )
end


function M._create_win(text)
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })

    -- Create a new window for the buffer
    local win = vim.api.nvim_open_win(buf, 10, true)

    -- Set the window's title
    win.set_title("My New Window")

    -- Set the window's size and position
    win.set_size(50, 30)
    win.set_position(10, 10)

    -- Make the window floating
    win.set_floating(true)
end

return M


