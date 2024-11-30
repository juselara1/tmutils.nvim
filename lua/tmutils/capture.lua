local F = require("tmutils.functions")

local M = {}

---Action to print the content in vim.
---@param data string[] # Content of a pane
local function capture_action_print(_, data, _)
	local clean_data = F.remove_empty_lines(data)
	vim.print(F.join_lines(clean_data))
end

---Action to add the content in a new buffer
---@param data string[] # Content of a pane
local function capture_action_newbuffer(_, data, _)
	local buf_num = vim.api.nvim_create_buf(false, true)
	local clean_data = F.remove_empty_lines(data)
	vim.api.nvim_buf_set_lines(buf_num, 0, -1, false, clean_data)
	vim.cmd.buffer(buf_num)
end

---Action to filter links
---@param data string[] # Content of a pane
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
---@param data string[] # Content of a pane
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

---Interface that defines a capture action.
---@alias CaptureAction fun(jobid: string, data: string[], event: string): nil

---Maps keys and capture actions.
---@type table<string, CaptureAction>
M.CaptureActionProxy = {
	files = capture_action_files,
	links = capture_action_links,
	newbuffer = capture_action_newbuffer,
	print = capture_action_print,
}

---Factory that creates the different actions on captured tmux content.
---@param action string # The action to take.
---@return CaptureAction # The Function that performs the action.
local function capture_action_factory(action)
	local fn = M.CaptureActionProxy[action]
	if fn == nil then
		error(string.format("Invalid action %s", action))
	end
	return fn
end

---Captures text from a tmux pane and performs an action on it.
---@param action string # The action to take.
---@param pane string # Target pane
local function capture(action, pane)
	local _ = vim.fn.jobstart(
		string.format("tmux capture-pane -p -t %s", pane),
		{
			on_stdout = capture_action_factory(action),
			stdout_buffered = true
		}
	)
end

---Captures the text content of a tmux pane and takes an action with that content.
---@param opts {args: string} # User command options.
---@param conf Config # Plugin configuration
M.tmux_capture = function (opts, conf)
	local args = vim.split(opts.args, ' ')
	if #args > 2 then
		error("Expected maximum two arguments")
	elseif #args == 2 then
		capture(args[1], args[2])
	elseif #args == 1 and vim.g.tmutils_selected_pane ~= nil then
		capture(args[1], vim.g.tmutils_selected_pane)
	elseif #args == 1 and vim.g.tmutils_selected_pane == nil then
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
							capture(args[1], vim.split(selected_opt, ' ')[1])
						end
						)
				end,
				stdout_buffered = true
			}
		)
	else
		error("Expected at least one argument, the capture action.")
	end
end

return M
