# 👁️llero 🦙

Ollero (ollero.nvim) is a Neovim Plugin that unleashes Ollama powers to your
text editor.

The backlog of this project includes features like:

- interact with offline LLM through Ollama API
- manage LLMs in Neovim
- selected to prompt
- manage AI Prompts (WIP 🚧)
- text completion (WIP 🚧)

## Dependencies

You must have `ollama` installed and running on your machine

> You can donwload and install Ollama from https://ollama.ai/

Also, this plugin relies on some other libraries that should be listed as
dependencies

```lua
-- Lazy plugin
{
  "marco-souza/ollero.nvim",
  name = "ollero",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    require("ollero").setup()
  end,
},
```

## Usage

Install it with your plugin manager, then add a keymap to the following command:

```sh
## Commands

# managing ollama models
:Chat
:RunModel <name>  # WIP 🚧
:ListModels
:RemoveModel
:InstallModel

# manafing model files
:CreateModel
:BuildModel
```
