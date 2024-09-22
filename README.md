# eval-replace.nvim

TODO: description

## Usage

TODO

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "fvictorio/eval-replace.nvim",
  config = function()
      local evalReplace = require("eval-replace")

      vim.keymap.set("n", "<leader>=", evalReplace.operator, { noremap = true })
      vim.keymap.set("n", "<leader>==", evalReplace.line, { noremap = true })
      vim.keymap.set("x", "<leader>=", evalReplace.visual, { noremap = true })
  end,
}
```

## Acknowledgements

Part of this code is inspired by [substitute.nvim](https://github.com/gbprod/substitute.nvim). The rest is stolen verbatim from [substitute.nvim](https://github.com/gbprod/substitute.nvim).
