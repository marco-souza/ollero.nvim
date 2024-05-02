Name = "Ollero"
Description = "A plugin to open an input box for chating with Ollama"

return {
  setup = function(opts)
    require("ollero.ollero").init(opts)
  end,
}
