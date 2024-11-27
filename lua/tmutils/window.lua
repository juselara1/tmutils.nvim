local F = require("tmutils.functions")
local M = {}

---@alias WindowDirection
---| "horizontal"
---| "vertical"

---@alias TerminalConfig {direction: WindowDirection, size: float, commands: fun():string[]}
---@alias WindowConfig {terminal: TerminalConfig, repls: {[string]: TerminalConfig}}}

---@param config TerminalConfig
local function make_terminal(config)
	local direction = config.direction == "vertical" and ' ' or " -h"
	local axis = config.direction == "vertical" and '-y' or "-x"

	local cur_pane = vim.fn.system("echo $TMUX_PANE")
	vim.fn.system("tmux split-window" .. direction)
	local _ = vim.fn.jobstart(
		"tmux list-panes",
		{
			stdout_buffered = true,
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
					.. tostring(config.size)
					.. "% -t %"
					.. tostring(recent_pane)
                )
				vim.fn.system(("tmux switch-client -t %s"):format(cur_pane))
				vim.g.tmutils_selected_pane = "%" .. tostring(recent_pane)
				vim.fn.system(
					("tmux send -t %s '%s' Enter"):format(
						vim.g.tmutils_selected_pane, F.join_lines(config.commands())
						)
					)
			end
		}
	)
end

---Creates a new terminal pane
---@param config WindowConfig
local function window_action_terminal(_, config)
	make_terminal(config.terminal)
end

---Creates a new repl pane
---@param args string[]
---@param config WindowConfig
local function window_action_repl(args, config)
	if #args ~= 2 then
		error("Expected the repl as an argument")
	end
	local repl_conf = config.repls[args[2]]
	vim.print(repl_conf)
	if repl_conf == nil then
		error(("Invalid repl: %s, please setup it in the window config."):format(args[2]))
	end
	make_terminal(repl_conf)
end

---Deletes a tmux pane
---@param args string[]
local function window_action_delete(args, _)
	local panes = {}
	if #args == 1 and vim.g.tmutils_selected_pane == nil then
		error("Expected the pane name/id or a configured pane at g:tmutils_selected_pane")
	elseif #args > 1 then
		for i = 2,#args do
			table.insert(panes, args[i])
		end
	elseif vim.g.tmutils_selected_pane ~= nil then
		panes = {vim.g.tmutils_selected_pane}
	end

	for _, pane in ipairs(panes) do
		vim.fn.system("tmux kill-pane -t " .. pane)
	end
end

---@type table<string, CaptureAction>
M.WindowActionProxy = {
	terminal = window_action_terminal,
	delete = window_action_delete,
	repl = window_action_repl,
}

---@alias WindowAction fun(args: string[], config: WindowConfig): nil

---Factory that creates different actions
---@param action string
---@return WindowAction
local function window_action_factory(action)
	local fn = M.WindowActionProxy[action]
	if fn == nil then
		error(string.format("Invalid action %s", action))
	end
	return fn
end

---Performs an action over a tmux window
---@param opts {args: string}
---@param config WindowConfig
M.tmux_window = function(opts, config)
	if opts.args:len() == 0 then
		error("Expected one argument")
	end
	local args = vim.split(opts.args, ' ')
	local action = args[1]
	window_action_factory(action)(args, config)
end

return M
