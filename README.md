# tmutils.nvim
---

`tmutils.nvim` is a Neovim plugin designed to streamline common development tasks that involve both `tmux` and Neovim. Key features include:

- Sending a range of lines from Neovim to a `tmux` pane.
- Collecting output from a `tmux` pane into Neovim.
- Creating a configurable `tmux` pane to serve as a terminal.
- Setting up and managing REPLs within `tmux` panes directly from Neovim.

## Installation
---

- `lazy`: to install this plugin using lazy:

    ```lua
    {
        "juselara1/tmutils.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim", -- Optional, use this only if you want to use the telescope selector.
        },
        config = function()
            require("tmutils").setup {
                selector = {
                    selector = "telescope" -- Optional, you can use tmutils using Ex commands only.
                },
                window = {
                    terminal = {
                        direction = "vertical", -- Split window direction to create a new pane.
                        size = 20, -- Size of the pane in percentage.
                        commands = function()
                            return {
                                ("cd %s"):format(vim.fn.getcwd()),
                                "clear"
                            }
                        end -- Commands to execute in the new terminal pane.
                    },
                    repls = {
                        py = {
                            direction = "vertical",
                            size = 20,
                            commands = function()
                                return {
                                    ("cd %s"):format(vim.fn.getcwd()),
                                    "clear",
                                    "python",
                                }
                            end
                        }, -- Configuration for a Python repl that will be accessed using the `py` keyword.
                        lua = {
                            direction = "vertical",
                            size = 20,
                            commands = function()
                                return {
                                    ("cd %s"):format(vim.fn.getcwd()),
                                    "clear",
                                    "lua",
                                }
                            end
                        }, -- Configuration for a Lua repl that will be accessed using the `lua` keyword.
                        -- You can add more repls here following the previous structure.
                    }
                }
            }
        end
        }
    ```

## Usage
---

Here are some common use cases for `tmutils`:

### Handling External Tmux Panes
---

<video src="https://github.com/user-attachments/assets/edfa1e47-526f-46d1-b341-dadc6e9fe06f"></video>

1. Set up a target pane: `:help :TmutilsConfig`.
2. Send a range of lines to the pane: `:help :TmutilsSend`.
3. Capture the pane's content into a buffer: `:help :TmutilsCapture`.

### Creating a Terminal in a Pane
---

<video src="https://github.com/user-attachments/assets/690b74db-ca71-43d3-ad7e-e760a4c2c149"></video>

1. Create a new terminal pane: `:help TmutilsWindow`.
2. Send a range of lines to the terminal: `:help :TmutilsSend`.
3. Delete the terminal: `:help TmutilsWindow`.

### Creating a REPL in a Pane
---

<video src="https://github.com/user-attachments/assets/73d4f072-cf81-432d-b5d4-bc600573bf7e"></video>

1. Create a new REPL pane (ensure the `window.repls.{repl}` option is set in your `setup`): `:help TmutilsWindow`.
2. Send a range of lines to the REPL: `:help :TmutilsSend`.
3. Delete the REPL: `:help TmutilsWindow`.
