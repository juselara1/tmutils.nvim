local F = require("tmutils.functions")

local M = {}

---Action to print the content in vim.
---@param data string[]
local function capture_action_print(_, data, _)
	local clean_data = F.remove_empty_lines(data)
	vim.print(F.join_lines(clean_data))
end

---Action to add the content in a new buffer
---@param data string[]
local function capture_action_newbuffer(_, data, _)
	local buf_num = vim.api.nvim_create_buf(false, true)
	local clean_data = F.remove_empty_lines(data)
	vim.api.nvim_buf_set_lines(buf_num, 0, -1, false, clean_data)
	vim.cmd.buffer(buf_num)
end

---Action to filter links
---@param data string[]
local function capture_action_links(_, data, _)
	local clean_data = F.remove_empty_lines(data)
	local text = F.join_lines(clean_data)

	-- Find all links
	local matches = F.all_matches(text, "https?://%S+")

	-- No matches
	if #matches == 0 then
		return
	end

	-- Add text to scratch
	local buf_num = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_num, 0, -1, false, matches)
	vim.cmd.buffer(buf_num)
end

---Action to filter files
---@param data string[]
local function capture_action_files(_, data, _)
	local clean_data = F.remove_empty_lines(data)
	local text = F.join_lines(clean_data)

	-- Find all links
	local matches = F.all_matches(text, "%S*/%S+/%S*")

	-- No matches
	if #matches == 0 then
		return
	end

	-- Add text to scratch
	local buf_num = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_num, 0, -1, false, matches)
	vim.cmd.buffer(buf_num)
end

---@alias CaptureAction fun(jobid: string, data: string[], event: string): nil

---@type table<string, CaptureAction>
M.CaptureActionProxy = {
	files = capture_action_files,
	links = capture_action_links,
	newbuffer = capture_action_newbuffer,
	print = capture_action_print,
}

---Factory that creates the different actions on captured tmux content.
---@param action string
---@return CaptureAction
local function capture_action_factory(action)
	local fn = M.CaptureActionProxy[action]
	if fn == nil then
		error(string.format("Invalid action %s", action))
	end
	return fn
end

---Captures the text content of a tmux pane and takes an action with that content.
---@param opts {args: string}
M.tmux_capture = function (opts)
	local args = vim.split(opts.args, ' ')
	local action = ""
	local pane = ""
	if #args > 2 then
		error("Expected maximum 2 arguments")
	elseif #args == 2 then
		action = args[1]
		pane = args[2]
	elseif #args == 1 then
		action = args[1]
		pane = vim.g.tmutils_selected_pane
	end
	local _ = vim.fn.jobstart(
		string.format("tmux capture-pane -p -t %s", pane),
		{
			on_stdout = capture_action_factory(action),
			stdout_buffered = true
		}
	)
end

return M
