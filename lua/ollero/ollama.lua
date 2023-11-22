local noop = require("shared.utils").noop
local exec = require("shared.utils").exec

local M = {}

function M.ask_ollama(input, callback)
  -- TODO: make this async to avoid blocking main thread to show loading
  local sh_script = "echo '" .. input .. "' | ollama run llama2"
  return exec(sh_script, callback)
end

function M.list(callback)
  -- local sh_script = "ollama ls | grep : | awk '{ printf \"%sv;%s;%s %s;%s %s %s\\n\", $1, $2, $3, $4, $5, $6, $7 }'"
  local sh_script = "ollama ls | grep :"
  return exec(sh_script, callback or noop)
end

return M
