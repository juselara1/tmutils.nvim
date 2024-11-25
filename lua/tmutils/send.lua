local F = require("tmutils.functions")

local M = {}

---Captures the text content of a tmux pane and takes an action with that content.
---@param opts {args: string, line1: integer, line2: integer}
M.tmux_send = function(opts)
	local args = vim.split(opts.args, ' ')
	if #args ~= 1 then
		error("Expected 1 arguments")
	end
	local pane = args[1]
	vim.print(opts.line1)
	vim.print(opts.line2)
	local text = F.join_lines(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false))
	local _ = vim.fn.jobstart(
		string.format("tmux send -t %s '%s' Enter", pane, text),
		{
			on_stdout = nil,
			stdout_buffered = true
		}
	)
end

return M
