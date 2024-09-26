local M = {}

function M.is_valid(str)
  str = str or ""
  return str and #str > 0
end

return M
