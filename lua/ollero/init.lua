Name = "Ollero"
Description = "A plugin to open an input box for chating with Ollama"

return {
  setup = function()
    require("ollero.ollero").init()
  end,
}
