local M = {}

function M.ask_ollama(input, callback)
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


function M.list()
  print("To be implemented")
  local sh_script = "ollama ls | grep : | awk '{ printf \"%sv;%s;%s %s;%s %s %s\n\", $1, $2, $3, $4, $5, $6, $7 }'"
  local output = vim.fn.system(sh_script)
  vim.notify(output)
end

return  M
