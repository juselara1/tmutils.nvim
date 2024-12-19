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
            --NOTE: you can optionally add one of these dependencies if you
            --want to use a custom selector different from the default vim.ui
            --selector.

            --"MunifTanjim/nui.nvim",
            --"nvim-telescope/telescope.nvim"
            --"vijaymarupudi/nvim-fzf"
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
local selectors = require("tmutils.selectors")
require("tmutils").setup {
    selector = {
        selector = selectors.vim_ui_selector
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
        selector = [[
        fun(
            opts: string[],
            message: string,
            callback: fun(selected_opt: string): nil
            ): nil
        ]]
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

- **Literate programming**:

    <video src="https://github.com/user-attachments/assets/f4d30cf9-ba1f-43f0-937f-fe48f075134d"></video>

    Let's see a more advanced example for literate programming using markdown as
    the base file format and an IPython repl:

    1. We'll use the `mini.ai` plugin to define a custom text object `x`
    (`vix` will select all the code inside of a cell that's usually delimited
    using a triple backquote). Let's see the configuration using `lazy.nvim`:

        ```lua
        {
            "echasnovski/mini.nvim",
            config = function()
                require("mini.ai").setup {
                    custom_textobjects = {
                        ---Code cell
                        x = { "```%S+%s()[^`]+()```" }
                        },
                    mappings = {
                        -- Main textobject prefixes
                        around = 'a',
                        inside = 'i',
                        },
                    search_method = "cover_or_next",
                    silent = true
                    }
                end
            }
        ```

    2. Let's configure the repl in `tmutils`:

        ```lua
        local selectors = require("tmutils.selectors")
        require("tmutils").setup {
            selector = {
                selector = selectors.nui_selector
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
                repls = {
                    --We configure here an IPython repl
                    ipython = {
                        direction = "vertical",
                        size = 20,
                        commands = function()
                            return {
                            ("cd %s"):format(vim.fn.getcwd()),
                            "ipython",
                            "clear",
                            }
                            end
                        },
                    }
                }
            }
        ```

    3. Now, we'll define some useful keybindings:

        ```lua
        --<leader>r creates a repl
        vim.keymap.set(
            'n', "<leader>r", ":TmutilsWindow repl<CR>",
            {
                noremap = true, silent=true,
                desc="Shows a menu to select and launch a repl"
                }
            )
        --<leader>x sends a code cell to the repl
        vim.keymap.set(
            'n', "<leader>x", function ()
                vim.cmd("norm vix")
                local pos_l = vim.fn.getpos('.')
                local pos_r = vim.fn.getpos('v')
                vim.cmd(("%d,%dTmutilsSend"):format(pos_l[2], pos_r[2]))
                vim.api.nvim_input("<Esc>")
                end,
            {
                noremap = true, silent=false,
                desc="Sends a code cell to a tmux pane"
                }
            )
        ```

    4. Open or create a markdown file, you can define Python cells using the
    following format:

        <code>
        ```python
        import os
        import sys
        ```
        </code>

    5. We can populate the quickfix list using `:vimgrep` to find the start of all
    the code cells. This allows an easy navigation between cells using `:cnext`
    and `:cprev`:

        ```vim
        :vim /\v```python/ %
        ```

    6. Open a new repl using `<leader>r`, navigate between cells using `:cnext`
    and `:cprev`, and execute them using `<leader>x`.
