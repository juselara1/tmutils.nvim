local M = {}

State = {
	scratch_buf = -1,
	scratch_win = -1
}

---Creates a scratch window and opens it.
---@param conf Config | {} # Plugin configuration.
---@param scratch_handler fun(buf: integer, win: integer):nil # Handler for the scratch window.
local function create_scratch_win(conf, scratch_handler)
	conf = conf or {}
	local scratch_conf = conf.scratch or {}
	local width = scratch_conf.width or math.floor(vim.o.columns * 0.8)
	local height = scratch_conf.height or math.floor(vim.o.lines * 0.8)
	local col = scratch_conf.col or math.floor((vim.o.columns - width) / 2)
	local row = scratch_conf.row or math.floor((vim.o.lines - height) / 3)
	local border = scratch_conf.border or "rounded"
	local title_pos = scratch_conf.title_pos or "center"

	local buf = -1
	if vim.api.nvim_buf_is_valid(State.scratch_buf) then
		buf = State.scratch_buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win_cfg = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = border,
		title = vim.g.tmutils_selected_repl or "sh",
		title_pos = title_pos
	}
	local win = vim.api.nvim_open_win(buf, true, win_cfg)
	scratch_handler(buf, win)
	State.scratch_buf = buf
	State.scratch_win = win
end

---Toggles a tmutils scratch.
---@param conf Config | {} # Plugin configuration.
M.toggle_scratch = function(_, conf)
	if not vim.api.nvim_win_is_valid(State.scratch_win) then
		create_scratch_win(conf, function (buf, win)
			vim.bo[buf].syntax = vim.g.tmutils_selected_repl or "sh"
			vim.bo[buf].filetype = vim.g.tmutils_selected_repl or "sh"
			vim.wo[win].number = true
			vim.wo[win].relativenumber = true
		end
		)
	else
		vim.api.nvim_win_hide(State.scratch_win)
	end
end

return M
