-- Log modules using plenary.log

local M = {}

function M.create_logger(opts)
  local logger = require("plenary.log"):new({
    plugin = "ollero",
    use_console = false,
    level = opts.log_level,
  })

  return logger
end

return M
