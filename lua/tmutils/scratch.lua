local M = {}

State = {
	scratch_buf = -1,
	scratch_win = -1
}

---Creates a scratch window and opens it.
---@param config Config # Plugin configuration.
local function create_scratch_win(config)
	local width = config.scratch.width or math.floor(vim.o.columns * 0.8)
	local height = config.scratch.height or math.floor(vim.o.lines * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 3)

	local buf = -1
	if vim.api.nvim_buf_is_valid(State.scratch_buf) then
		buf = State.scratch_buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].syntax = vim.g.tmutils_selected_repl or "sh"
		vim.bo[buf].filetype = vim.g.tmutils_selected_repl or "sh"
	end

	local win_cfg = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded"
	}
	local win = vim.api.nvim_open_win(buf, true, win_cfg)
	vim.wo[win].number = true
	vim.wo[win].relativenumber = true
	State.scratch_buf = buf
	State.scratch_win = win
end

---Toggles a tmutils scratch.
---@param config Config # Plugin configuration.
M.toggle_scratch = function(_, config)
	if not vim.api.nvim_win_is_valid(State.scratch_win) then
		create_scratch_win(config)
	else
		vim.api.nvim_win_hide(State.scratch_win)
	end
end

return M
