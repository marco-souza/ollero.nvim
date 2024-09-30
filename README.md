<h1 align="center">👁️llero 🦙</h1>
<div>
  <h4 align="center">
    <a href="#dependencies">Dependencies</a> ·
    <a href="#usage">Usage</a>
  </h4>
</div>
<div align="center">
  <a href="https://github.com/marco-souza/ollero.nvim/releases/latest"
    ><img
      alt="Latest release"
      src="https://img.shields.io/github/v/release/marco-souza/ollero.nvim?style=for-the-badge&logo=starship&logoColor=D9E0EE&labelColor=302D41&&color=d9b3ff&include_prerelease&sort=semver"
  /></a>
  <a href="https://github.com/marco-souza/ollero.nvim/pulse"
    ><img
      alt="Last commit"
      src="https://img.shields.io/github/last-commit/marco-souza/ollero.nvim?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f"
  /></a>
  <a href="https://github.com/neovim/neovim/releases/latest"
    ><img
      alt="Latest Neovim"
      src="https://img.shields.io/github/v/release/neovim/neovim?style=for-the-badge&logo=neovim&logoColor=D9E0EE&label=Neovim&labelColor=302D41&color=99d6ff&sort=semver"
  /></a>
  <a href="http://www.lua.org/"
    ><img
      alt="Made with Lua"
      src="https://img.shields.io/badge/Built%20with%20Lua-grey?style=for-the-badge&logo=lua&logoColor=D9E0EE&label=Lua&labelColor=302D41&color=b3b3ff"
  /></a>
  <!-- <a href="https://www.buymeacoffee.com/marco-souza" -->
  <!--   ><img -->
  <!--     alt="Buy me a coffee" -->
  <!--     src="https://img.shields.io/badge/Buy%20me%20a%20coffee-grey?style=for-the-badge&logo=buymeacoffee&logoColor=D9E0EE&label=Sponsor&labelColor=302D41&color=ffff99" -->
  <!-- /></a> -->
</div>
<hr />

Ollero (`ollero.nvim`) is a Neovim Plugin that unleashes Ollama powers to your
text editor.

**🚀 Features**
- interact with offline LLM using Ollama - https://ollama.com/
- manage Ollama models in Neovim
- Chat with the default model using `<M-a>`
- selected to prompt using `<M-s>`
- list online and offline models
- build and run custom ollama modelfile
- generate `Modelfile` based on prompt input _(using [marco-souza/omg](https://github.com/marco-souza/omg))

## Demo

https://www.loom.com/share/a61362b16dc94c4b82426a03f0797099

## Dependencies

Ollero run [ollama](https://ollama.ai/), so you must have `ollama` installed and running on your machine.

Also, this plugin relies on some other libraries that should be listed as dependencies

```lua
-- Lazy plugin
{
  "marco-souza/ollero.nvim",
  build = ":!go install github.com/marco-souza/omg@latest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "marco-souza/term.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = true,
},
```

## Usage

Install it with your plugin manager, then add a keymap to the following command:

```sh
## Commands

# managing ollama models
:InstallModel
:RemoveModel
:ListModels
:RunModel

# interact with models
:Chat
:Ask

# custom model files
:CreateModel
:BuildModel
```
