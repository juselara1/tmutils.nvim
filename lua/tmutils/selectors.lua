F = require("tmutils.functions")
local M = {}

---@alias Selector fun(opts: string[], message: string, callback: fun(selected_opt: string): nil): nil

---Select an option using default vim.ui
---@param opts string[] # Options to select.
---@param message string # Message that is displayed to the user.
---@param callback fun(selected_opt: string): nil # Function to call on the selected option.
M.vim_ui_selector = function (opts, message, callback)
	vim.ui.select(opts, {
		prompt = message,
	},
	function (selected_opt)
		if F.isin(selected_opt, opts) then
			callback(selected_opt)
		end
	end)
end

---Select an option using telescope
---@param opts string[] # Options to select.
---@param message string # Message that is displayed to the user.
---@param callback fun(selected_opt: string): nil # Function to call on the selected option.
M.telescope_selector = function (opts, message, callback)
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local tconfig = require("telescope.config").values
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")
	pickers.new({}, {
        prompt_title = message,
        finder = finders.new_table {results = opts},
        sorter = tconfig.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
				callback(action_state.get_selected_entry().value)
                actions.close(prompt_bufnr)
            end)
            return true
        end,
    }):find()
end

---Select an option using nui
---@param opts string[] # Options to select.
---@param message string # Message that is displayed to the user.
---@param callback fun(selected_opt: string): nil # Function to call on the selected option.
M.nui_selector = function (opts, message, callback)
	local Menu = require("nui.menu")

	local menu_items = F.map(opts, Menu.item)
	local menu = Menu({
		position = "50%",
		size = {width = 25, height = 5},
		border = {
			style = "single",
			text = {
				top = message,
				top_align = "center",
				},
			},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
			},
		}, {
			lines = menu_items,
			max_width = 20,
			keymap = {
				focus_next = { "j", "<Down>", "<Tab>" },
				focus_prev = { "k", "<Up>", "<S-Tab>" },
				close = { "<Esc>", "<C-c>" },
				submit = { "<CR>", "<Space>" },
				},
			on_close = function() end,
			on_submit = function(item)
				callback(item.text)
			end,
		})

	-- mount the component
	menu:mount()
end

---Select an option using fzf
---@param opts string[] # Options to select.
---@param message string # Message that is displayed to the user.
---@param callback fun(selected_opt: string): nil # Function to call on the selected option.
M.fzf_selector = function(opts, message, callback)
	local fzf = require("fzf")
	coroutine.wrap(function()
		local result = fzf.fzf(opts, "--nth 1", {title=message})
		if result then
			callback(result[1])
		end
	end
	)()
end


return M
