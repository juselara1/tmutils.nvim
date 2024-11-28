local F = require("tmutils.functions")

local M = {}

---Captures the text content of a tmux pane and takes an action with that content.
---@param opts {args: string, line1: integer, line2: integer} # User command options.
M.tmux_send = function(opts)
	local pane = ""
	if opts.args:len() == 0 then
		pane = vim.g.tmutils_selected_pane or error("g:tmutils_selected_pane has not been configured, use :TmutilsConfig")
	else
		local args = vim.split(opts.args, ' ')
		if #args ~= 1 then
			error("Expected 1 arguments")
		end
		pane = args[1]
	end

	local lines = F.map(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false), F.str2cmd)
	local text = F.join_lines(lines)
	vim.print(text)
	local _ = vim.fn.jobstart(
		string.format("tmux send -t %s \"%s\" Enter", pane, text),
		{
			on_stdout = nil,
			stdout_buffered = true
		}
	)
end

return M
