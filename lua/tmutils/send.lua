local selectors = require("tmutils.selectors")
local F = require("tmutils.functions")

local M = {}

---Sends lines to a tmux pane.
---@param lines string[]
---@param pane string
local function send_lines(lines, pane)
	local text = F.join_lines(lines)
	local _ = vim.fn.jobstart(
		string.format("tmux send -t %s \"%s\"", pane, text),
		{
			on_stdout = nil,
			stdout_buffered = true
		}
	)
end

---Sends a range of line into a tmux pane.
---@param opts {args: string, line1: integer, line2: integer} # User command options.
---@param conf Config | {} # Plugin configuration
M.tmux_send = function(opts, conf)
	local lines = F.map(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false), F.str2cmd)
	local selector_conf = conf.selector or {selector = selectors.vim_ui_selector}
	local selector = selector_conf.selector or selectors.vim_ui_selector
	if opts.args:len() ~= 0 then
		local args = vim.split(opts.args, ' ')
		if #args ~= 1 then
			error("Expected 1 arguments")
		end
		send_lines(lines, args[1])
	elseif vim.g.tmutils_selected_pane ~= nil then
		send_lines(lines, vim.g.tmutils_selected_pane)
	else
		local _ = vim.fn.jobstart(
			"tmux list-panes -a",
			{
				---@param data string[]
				on_stdout = function(_, data, _)
					local matches = F.parse_tmux_panes(data)
					selector(
						F.map(matches, F.pane2str),
						"Select a pane:",
						function (selected_opt)
							send_lines(lines, vim.split(selected_opt, ' ')[1])
						end
						)
				end,
				stdout_buffered = true
			}
		)
	end

end

return M
