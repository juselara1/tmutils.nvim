# tmutils.nvim
---

```
   ██                         ██   ██  ██                              ██
  ░██                        ░██  ░░  ░██                             ░░
 ██████ ██████████  ██   ██ ██████ ██ ░██  ██████    ███████  ██    ██ ██ ██████████
░░░██░ ░░██░░██░░██░██  ░██░░░██░ ░██ ░██ ██░░░░    ░░██░░░██░██   ░██░██░░██░░██░░██
  ░██   ░██ ░██ ░██░██  ░██  ░██  ░██ ░██░░█████     ░██  ░██░░██ ░██ ░██ ░██ ░██ ░██
  ░██   ░██ ░██ ░██░██  ░██  ░██  ░██ ░██ ░░░░░██ ██ ░██  ░██ ░░████  ░██ ░██ ░██ ░██
  ░░██  ███ ░██ ░██░░██████  ░░██ ░██ ███ ██████ ░██ ███  ░██  ░░██   ░██ ███ ░██ ░██
   ░░  ░░░  ░░  ░░  ░░░░░░    ░░  ░░ ░░░ ░░░░░░  ░░ ░░░   ░░    ░░    ░░ ░░░  ░░  ░░
```

`tmutils.nvim` is a Neovim plugin designed to streamline common development tasks that involve both `tmux` and Neovim. Key features include:

- Sending a range of lines from Neovim to a `tmux` pane.
- Collecting output from a `tmux` pane into Neovim.
- Creating a configurable `tmux` pane to serve as a terminal.
- Setting up and managing REPLs within `tmux` panes directly from Neovim.

For a more detailed guide and documentation, review the help page: `:help tmutils.txt`

## Installation
---

- `lazy`: to install this plugin using lazy:

    ```lua
    {
        "juselara1/tmutils.nvim",
        dependencies = {
                --NOTE: you only need one of these dependencies depending on the
                --selector that you want to use, defaults to nui.
                "MunifTanjim/nui.nvim",
                --"nvim-telescope/telescope.nvim"
        },
        config = function()
                require("tmutils").setup()
        end
    }
    ```

## Configuration
---

Let's see the default and minimal `tmutils` config:

```lua
require("tmutils").setup {
    selector = {
        selector = "nui"
    },
    window = {
        terminal = {
            direction = "vertical",
            size = 20,
            commands = function()
                return {
                    ("cd %s"):format(vim.fn.getcwd()),
                    "clear"
                    }
                end
            },
        repls = {}
    }
}
```

The configuration table has the following schema (review `LuaLS` type specification for the type annotations):

```lua
{
    --Configuration for UI-based selection.
    selector = {
        --The backend used to select options.
        selector = '"telescope" | "nui"'
    },
    --Configuration for window management commands.
    window = {
        --Configuration for the terminal pane.
        terminal = {
            --Direction in which to split the terminal pane.
            direction = '"vertical" | "horizontal"',
            --Relative size (in percentage) for the terminal pane.
            size = 'number',
            --Function that returns a list of commands to be executed
            --when launching a new terminal pane.
            commands = 'fun(): string[]'
        },
        repls = {
            --Assign a key to the repl
            repl1 = {
                --Direction in which to split the repl pane.
                direction = '"vertical" | "horizontal"',
                --Relative size (in percentage) for the repl pane.
                size = 'number',
                --Function that returns a list of commands to be executed
                --when launching a new repl pane.
                commands = 'fun(): string[]'
            },
            --Assign a key to the repl
            repl2 = {
                --Direction in which to split the repl pane.
                direction = '"vertical" | "horizontal"',
                --Relative size (in percentage) for the repl pane.
                size = 'number',
                --Function that returns a list of commands to be executed
                --when launching a new repl pane.
                commands = 'fun(): string[]'
            },
        --Create other repls following the same structure.
        }
    }
}
```

## Usage
---

A comprehensive usage guide can be read in the help page: `:help tmutils-usage`. However, here are some
examples of it:

- **Handling external panes**:

    <video src="https://github.com/user-attachments/assets/edfa1e47-526f-46d1-b341-dadc6e9fe06f"></video>

    1. Set up a target pane: `:help :TmutilsConfig`.
    2. Send a range of lines to the pane: `:help :TmutilsSend`.
    3. Capture the pane's content into a buffer: `:help :TmutilsCapture`.

- **Creating a terminal pane**:

    <video src="https://github.com/user-attachments/assets/690b74db-ca71-43d3-ad7e-e760a4c2c149"></video>

    1. Create a new terminal pane: `:help TmutilsWindow`.
    2. Send a range of lines to the terminal: `:help :TmutilsSend`.
    3. Delete the terminal: `:help TmutilsWindow`.

- **Creating a repl pane**:

    <video src="https://github.com/user-attachments/assets/73d4f072-cf81-432d-b5d4-bc600573bf7e"></video>

    1. Create a new REPL pane (ensure the `window.repls.{repl}` option is set in your `setup`): `:help TmutilsWindow`.
    2. Send a range of lines to the REPL: `:help :TmutilsSend`.
    3. Delete the REPL: `:help TmutilsWindow`.
