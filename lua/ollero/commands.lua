local M = {}

function M.apply_commands(mappings, opts)
  for command, handler in pairs(mappings) do
    vim.api.nvim_create_user_command(command, handler, opts or {})
  end
end

function M.apply_mappings(mappings)
  for mapping, handler in pairs(mappings) do
    vim.keymap.set(
      { "n", "v", "i", "t" },
      mapping,
      handler,
      { noremap = true, silent = true }
    )
  end
end

local CommandBuilder = {}

function CommandBuilder:new(opts)
  local obj = { internal_cmd = "" }

  setmetatable(obj, self)
  self.__index = self

  return obj
end

function CommandBuilder:interactive()
  return self
end

function CommandBuilder:run(input)
  self.internal_cmd = input .. " "
  return self
end

function CommandBuilder:build()
  return self.internal_cmd
end

M.CommandBuilder = CommandBuilder

return M
