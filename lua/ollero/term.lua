local w = require("ollero.floating-input")

-- constructor
local title = "👁️llero 🦙"
local buf = vim.api.nvim_create_buf(false, true)
local win = vim.api.nvim_open_win(buf, true, w.win_config({ prompt = title }))

---manage terminal
local Term = {}

---check if a buffer is visible
---@param buffer uv.buffer
---@return boolean
local function is_buf_hidden(buffer)
  -- vim.api.nvim_buf_set_name(buf, "term://" .. cmd)
  local buf_info = vim.fn.getbufinfo(buffer)[1]
  return buf_info.hidden == 1
end

local function show_term()
  win = vim.api.nvim_open_win(
    buf,
    true,
    w.win_config({ prompt = title, win = win })
  )

  -- setup window
  vim.wo.relativenumber = false
  vim.o.number = false
  vim.bo.buflisted = false
  vim.wo.foldcolumn = "0"

  vim.cmd("startinsert")
end

---toggle terminal
function Term.toggle()
  if is_buf_hidden(buf) then
    -- show
    show_term()
  else
    -- hide
    vim.api.nvim_win_hide(win)
  end
end

---@param cmd string
function Term.start(cmd)
  if is_buf_hidden(buf) then
    show_term()
  end

  -- vim.api.nvim_buf_set_name(buf, "term://" .. cmd)
  vim.cmd("term " .. cmd)

  vim.api.nvim_win_hide(win)
end

---@param cmd string
function Term.send(cmd)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_chan_send(buf, cmd)
  end
end

return Term
