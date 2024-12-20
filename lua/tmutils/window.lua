local F = require("tmutils.functions")
local M = {}

---Creates a pane using certain configuration that runs some given commands.
---@param config TerminalConfig # Terminal configuration.
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

---Creates a new plain terminal pane
---@param conf Config # Plugin configuration.
local function window_action_terminal(_, conf)
	make_terminal(conf.window.terminal)
end

---Creates a new repl pane.
---@param args string[] # User command provided args.
---@param conf Config # Plugin configuration.
local function window_action_repl(args, conf)
	if #args == 2 then
		local repl_conf = conf.window.repls[args[2]]
		vim.g.tmutils_selected_repl = repl_conf.syntax
		if repl_conf == nil then
			error(("Invalid repl: %s, please set it up in the window config."):format(args[2]))
		end
		make_terminal(repl_conf)
	else
		local opts = {}
		for k, _ in pairs(conf.window.repls) do
			table.insert(opts, k)
		end
		conf.selector.selector(opts, "Select a repl:", function (selected_opt)
			local repl_conf = conf.window.repls[selected_opt]
			vim.g.tmutils_selected_repl = repl_conf.syntax
			make_terminal(repl_conf)
		end)
	end
end

---Deletes a tmux pane.
---@param args string[] # User command provided args (panes to delete), if empty, tries to delete `g:tmutils_selected_pane`.
---@param conf Config # Plugin configuration.
local function window_action_delete(args, conf)
	if #args == 1 and vim.g.tmutils_selected_pane == nil then
		local _ = vim.fn.jobstart(
			"tmux list-panes -a",
			{
				---@param data string[]
				on_stdout = function(_, data, _)
					local matches = F.parse_tmux_panes(data)
					conf.selector.selector(
						F.map(matches, F.pane2str),
						"Select a pane:",
						function (selected_opt)
							vim.fn.system("tmux kill-pane -t " .. vim.split(selected_opt, ' ')[1])
						end
						)
				end,
				stdout_buffered = true
			}
		)
	end

	local panes = {}
	if #args > 1 then
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

---Proxy that maps keys and functions for window actions.
---@type table<string, CaptureAction>
M.WindowActionProxy = {
	terminal = window_action_terminal,
	delete = window_action_delete,
	repl = window_action_repl,
}

---Interface that defines a possible window action.
---@alias WindowAction fun(args: string[], config: Config): nil

---Factory that creates different actions
---@param action string # Window action to take.
---@return WindowAction # Function that performs a window action.
local function window_action_factory(action)
	local fn = M.WindowActionProxy[action]
	if fn == nil then
		error(string.format("Invalid action %s", action))
	end
	return fn
end

---Performs an action over a tmux window
---@param opts {args: string} # User command arguments.
---@param config Config # Plugin configuration.
M.tmux_window = function(opts, config)
	if opts.args:len() == 0 then
		error("Expected one argument")
	end
	local args = vim.split(opts.args, ' ')
	local action = args[1]
	window_action_factory(action)(args, config)
end

return M
