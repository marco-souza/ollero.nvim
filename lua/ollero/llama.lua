local M = {}


function M.ask_llama(input, callback)
  -- TODO: make this async to avoid blocking main thread to show loading
  local shellCmd = "echo '" .. input .. "' | ollama run llama2"
  local handler = io.popen(shellCmd)
  if not handler then
    return error("Cannot execute shell command")
  end

  local output = handler:read("*a")
  handler:close()

  callback(output)

  return output
end

return M
