Name = "Ollero"
Description = "A plugin to open an input box for chating with Ollama"

---@class OlleroOptions
---@field model OllamaModels -- any model present at https://ollama.ai/models
---@field log_level 'debug' | 'info' | 'warn' | 'error'

---@type OlleroOptions
local default_options = {
  model = "llama3.1",
  log_level = "debug",
}

local M = {
  ---@param opts OlleroOptions
  setup = function(opts)
    opts = vim.tbl_deep_extend("force", default_options, opts or {})

    local registration_list = {
      logger = require("shared.logger").create_logger(opts),
      term = function()
        return require("term.term"):new({ title = "👁️🦙 Ask Ollero " })
      end,
      ollama = function()
        return require("ollama.ollama")
      end,
    }

    for name, value in pairs(registration_list) do
      require("di").register({ name = name, value = value })
    end

    require("ollero.ollero").init(opts)
  end,
}

return M
