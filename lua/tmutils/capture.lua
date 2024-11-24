local F = require("tmutils.functions")

local M = {}

---Action to print the content in vim.
---@param data table
local function capture_action_print(_, data, _)
	local clean_data = F.remove_empty_lines(data)
	vim.print(F.join_lines(clean_data))
end

---Action to add the content in a new buffer
---@param data table
local function capture_action_newbuffer(_, data, _)
	local buf_num = vim.api.nvim_create_buf(false, true)
	local clean_data = F.remove_empty_lines(data)
	vim.api.nvim_buf_set_lines(buf_num, 0, -1, false, clean_data)
	vim.cmd.buffer(buf_num)
end

---@alias CaptureAction fun(jobid: string, data: table, event: string): nil

---@type table<string, CaptureAction>
local CaptureActionProxy = {
	print = capture_action_print,
	newbuffer = capture_action_newbuffer
}

---Factory that creates the different actions on captured tmux content.
---@param action string
---@return CaptureAction
local function capture_action_factory(action)
	---@type CaptureAction
	local fn = CaptureActionProxy[action]
	if fn == nil then
		error(string.format("Invalid action %s", action))
	end
	return fn
end

---Captures the text content of a tmux pane and takes an action with that content.
---@param opts {args: string}
M.tmux_capture = function (opts)
	local args = vim.split(opts.args, ' ')
	if #args ~= 2 then
		error("Expected 2 arguments")
	end
	local pane = args[1]
	local action = args[2]
	local _ = vim.fn.jobstart(
		string.format("tmux capture-pane -p -t %s", pane),
		{
			on_stdout = capture_action_factory(action),
			stdout_buffered = true
		}
	)
end

return M
