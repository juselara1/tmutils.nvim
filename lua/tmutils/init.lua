local capture = require("tmutils.capture")
local send = require("tmutils.send")
local config = require("tmutils.config")
local window = require("tmutils.window")

local M = {}

---@param conf {config: {selector: string}, window: {terminal: {direction: WindowDirection, size: float}}}
M.setup = function (conf)
	vim.api.nvim_create_user_command("TmutilsCapture", capture.tmux_capture, {
		nargs = '?',
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
	vim.api.nvim_create_user_command("TmutilsSend", send.tmux_send, {
		nargs = '?', range=true,
		desc = "Sends a range of lines to a tmux pane."
	})
	vim.api.nvim_create_user_command("TmutilsConfig", function (opts) config.tmux_config(opts, conf) end, {
		nargs = '?',
		desc = "Configures the tmux pane to use."
	})
	vim.api.nvim_create_user_command("TmutilsWindow", function (opts) window.tmux_window(opts, conf) end, {
		nargs = 1,
		desc = "Creates a pane and configures it as the target pane."
	})
end

return M
