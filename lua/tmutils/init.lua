local capture = require("tmutils.capture")
local send = require("tmutils.send")
local config = require("tmutils.config")
local window = require("tmutils.window")
local scratch = require("tmutils.scratch")

local M = {}

---Defines config command configuration.
---@alias SelectorConfig {selector: Selector | nil}

--- Defines the possible window directions.
---@alias WindowDirection
---| "horizontal"
---| "vertical"

---Defines terminal configuration.
---@alias TerminalConfig {direction: WindowDirection | nil, size: float | nil, syntax: string | nil, commands: (fun():string[]) | nil}

---Defines window command configuration.
---@alias WindowConfig {terminal: TerminalConfig | nil, repls: {[string]: TerminalConfig} | nil}

---Defines border configuration.
---@alias Border
---| "none" # No border.
---| "single" # Single border.
---| "double" # Double border.
---| "rounded" # Rounded border.
---| "solid" # Solid border.
---| "shadow" # Shadow border.

---Defines title position configuration.
---@alias TitlePos
---| "center" # Centered title.
---| "left" # Left indented title.
---| "right" # Right indented title.

---Defines scratch configuration.
---@alias ScratchConfig {width: integer | nil, height: integer | nil, col: integer | nil, row: integer | nil, border: Border | nil, title_pos: TitlePos | nil}
---
---Defines plugin configuration
---@alias Config {selector: SelectorConfig | nil, window: WindowConfig | nil, scratch: ScratchConfig | nil}

---Main plugin configuration.
---@param conf Config | {} # Main plugin configuration
M.setup = function (conf)
	vim.api.nvim_create_user_command("TmutilsCapture", function (opts) capture.tmux_capture(opts, conf) end, {
		nargs = 1,
		desc = "Captures the text content from a tmux pane and takes an action on it.",
		complete = function (_, _, _)
			local opts = {}
			for name, _ in pairs(capture.CaptureActionProxy) do
				table.insert(opts, name)
			end
			return opts
		end
		}
    )
	vim.api.nvim_create_user_command("TmutilsConfig", function (opts) config.tmux_config(opts, conf) end, {
		nargs = '?',
		desc = "Configures the tmux pane to use."
	})
	vim.api.nvim_create_user_command("TmutilsSend", function (opts) send.tmux_send(opts, conf) end, {
		nargs = '?', range=true,
		desc = "Sends a range of lines to a tmux pane."
	})
	vim.api.nvim_create_user_command("TmutilsWindow", function (opts) window.tmux_window(opts, conf) end, {
		nargs = 1,
		desc = "Creates a pane and configures it as the target pane.",
		complete = function (_, _, _)
			local opts = {}
			for name, _ in pairs(window.WindowActionProxy) do
				table.insert(opts, name)
			end
			return opts
		end
	})
	vim.api.nvim_create_user_command("TmutilsScratchToggle", function (opts) scratch.toggle_scratch(opts, conf) end, {
		nargs = 0,
		desc = "Toggles a tmutils scratch."
	})
end

return M
