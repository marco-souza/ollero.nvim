local M = {}

function M.apply_commands(mappings, opts)
  opts = opts or {}
  for command, handler in pairs(mappings) do
    vim.api.nvim_create_user_command(command, handler, opts[command] or {})
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

return M
