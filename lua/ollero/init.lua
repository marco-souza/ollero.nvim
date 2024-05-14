Name = "Ollero"
Description = "A plugin to open an input box for chating with Ollama"

---@class OlleroOptions
---@field model 'llama2' | 'llama3'

local M = {
  ---@param opts OlleroOptions
  setup = function(opts)
    require("ollero.ollero").init(opts)
  end,
}

return M
