local F = require("tmutils.functions")
local M = {}

---@alias WindowDirection
---| "horizontal"
---| "vertical"

---Performs an action over a tmux window
---@param opts {args: string}
---@param config {window: {terminal: {direction: WindowDirection, size: float}}}
M.tmux_window = function(opts, config)
	local args = vim.split(opts.args, ' ')

	if opts.args:len() == 0 or #args > 1 then
		error("Expected one argument")
	end

	local direction = config.window.terminal.direction == "vertical" and ' ' or " -h"
	local axis = config.window.terminal.direction == "vertical" and '-y' or "-x"

	local cur_pane = vim.fn.system("echo $TMUX_PANE")
	vim.fn.system("tmux split-window" .. direction)
	local _ = vim.fn.jobstart(
		"tmux list-panes",
		{
			on_stdout = function (_, data, _)
				local panes = F.parse_tmux_panes(data, true)
				local recent_pane = 0
				for _, pane in ipairs(panes) do
					local pane_id = tonumber(pane.pane_id:sub(2))
					if pane_id == nil then
						error("Error while parsing tmux panes")
					end
					if pane_id > recent_pane then
						recent_pane = pane_id
					end
				end
				vim.fn.system(
                    "tmux resize-pane "
					.. axis .. " "
					.. tostring(config.window.terminal.size)
					.. "% -t %"
					.. tostring(recent_pane)
                )
				vim.fn.system(("tmux switch-client -t %s"):format(cur_pane))
				vim.g.tmutils_selected_pane = recent_pane
			end
		}
	)
end

return M
