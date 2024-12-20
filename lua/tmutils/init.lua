local capture = require("tmutils.capture")
local send = require("tmutils.send")
local config = require("tmutils.config")
local window = require("tmutils.window")
local scratch = require("tmutils.scratch")

local M = {}

---Defines config command configuration.
---@alias SelectorConfig {selector: Selector}

--- Defines the possible window directions.
---@alias WindowDirection
---| "horizontal"
---| "vertical"

---Defines terminal configuration.
---@alias TerminalConfig {direction: WindowDirection, size: float, syntax: string, commands: fun():string[]}

---Defines window command configuration.
---@alias WindowConfig {terminal: TerminalConfig, repls: {[string]: TerminalConfig}}}

---Defines scratch configuration.
---@alias ScratchConfig {width: float, height: float}

---Defines plugin configuration
---@alias Config {selector: SelectorConfig, window: WindowConfig, scratch: ScratchConfig}

---Main plugin configuration.
---@param conf Config | nil # Main plugin configuration
M.setup = function (conf)
	local valid_conf = config.make_default_config(conf)
	vim.api.nvim_create_user_command("TmutilsCapture", function (opts) capture.tmux_capture(opts, valid_conf) end, {
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
	vim.api.nvim_create_user_command("TmutilsSend", function (opts) send.tmux_send(opts, valid_conf) end, {
		nargs = '?', range=true,
		desc = "Sends a range of lines to a tmux pane."
	})
	vim.api.nvim_create_user_command("TmutilsConfig", function (opts) config.tmux_config(opts, valid_conf) end, {
		nargs = '?',
		desc = "Configures the tmux pane to use."
	})
	vim.api.nvim_create_user_command("TmutilsWindow", function (opts) window.tmux_window(opts, valid_conf) end, {
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
	vim.api.nvim_create_user_command("TmutilsScratch", function (opts) scratch.toggle_scratch(opts, valid_conf) end, {
		nargs = 0,
		desc = "Toggles a tmutils scratch."
	})
end

return M
