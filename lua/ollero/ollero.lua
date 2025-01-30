local di = require("di")
local strings = require("shared.strings")
local commands = require("shared.commands")
local utils = require("shared.utils")

local term = di.resolve("term")
local logger = di.resolve("logger")
local ollama = di.resolve("ollama")

---Manage Window and Ollama interaction
local M = {}

---Initialize Ollero module
function M.init(opts)
  -- dependencies setup
  require("telescope").load_extension("ui-select")

  local model = opts.model or "deepseek-r1:8b"

  -- setup
  term.win:show()
  ollama.run(model)
  term.win:hide()

  commands.apply_commands({
    ["OlleroChat"] = M.chat,
    ["OlleroRun"] = M.run_model,
    ["OlleroListModels"] = M.list_models,
    ["OlleroRemove"] = M.remove_model,
    ["OlleroBuild"] = M.build_model,
    ["OlleroCreate"] = M.create_model,
    ["OlleroInstall"] = M.install_model,
    ["OlleroAsk"] = M.ask,
  }, {
    BuildModel = { nargs = "*" },
    CreateModel = { nargs = "*" },
    Ask = { nargs = "*" },
  })

  commands.apply_mappings({
    ["<M-a>"] = function()
      vim.cmd("OlleroChat")
    end,
    ["<M-s>"] = function()
      -- hit <esc> to exit visual mode and mark the selection
      local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
      vim.api.nvim_feedkeys(esc, "m", false)

      vim.schedule(function()
        -- get selected text in v mode
        local sep = "<br>"
        local text = utils.get_selected_text(sep)

        if not strings.is_valid(text) then
          logger.error("invalid text selected", text)
          return
        end

        local prompt = string.gsub(
          "I want to ask some questions about the following code %sep %text %sep\n",
          "%S+",
          { ["%sep"] = sep, ["%text"] = text }
        )

        M.ask({ args = prompt })
      end)
    end,
  })
end

---Open chat
function M.chat()
  term.win:toggle()
end

-- Ask to open gpt chat
function M.ask(opts)
  logger.debug("Asking question: ", opts)

  local question = opts.args
  if question == nil then
    logger.error("No question provided")
    return
  end

  term:send(question)
  term.win:toggle()
end

---List Models
function M.list_models()
  local options = ollama.list()
  local online_options = ollama.fetch_models()

  options[#options] = "-----------------"

  for _, model in ipairs(online_options) do
    if strings.is_valid(model) then
      table.insert(options, model .. " (remote)")
    end
  end

  ---@param choice string
  local function on_select(choice)
    vim.notify("Selected model: " .. choice)

    term.win:show()
    term:send(term:termcode("<C-d>")) -- stop
    ollama.run(choice) -- kickoff new model
  end

  vim.ui.select(options, { prompt = "List of Ollama Models" }, on_select)
end

---List Models
function M.install_model()
  local options = ollama.fetch_models()

  vim.ui.select(
    options,
    { prompt = "📦 Select an Ollama Model to install" },
    function(choice)
      vim.notify("Installing model: " .. choice)
      ollama.install(choice)
    end
  )
end

---Remove Model
function M.remove_model()
  local options = ollama.list()

  vim.ui.select(
    options,
    { prompt = "🗑️ Select an Ollama Model to remove" },
    function(choice)
      vim.notify("Removing model: " .. choice)
      ollama.remove(choice)
      vim.notify("Model " .. choice .. " removed")
    end
  )
end

---Build Model
function M.build_model(opts)
  local filename = opts.args or "Modelfile"

  vim.ui.input({ prompt = "Enter model name: " }, function(name)
    vim.schedule(function()
      ollama.build_model(name, filename)
    end)
  end)
end

---Create Model
function M.create_model(opts)
  vim.ui.input({
    prompt = "Enter a prompt to generate your file (enter to skip): ",
  }, function(prompt)
    vim.schedule(function()
      ollama.create_modelfile(prompt, opts.args)
    end)
  end)
end

return M
