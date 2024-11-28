local M = {}

---Selector configuration.
---@alias SelectorConfig {selector: string}

---Selects a pane using telescope.
---@param panes TmuxPane[] # Parsed tmux panes.
local function config_selector_telescope(panes)
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local tconfig = require("telescope.config").values
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")

	local options = {}
	for _, pane in ipairs(panes) do
		table.insert(options, ("%s %s"):format(pane.pane_id, pane.pane_name))
	end

	pickers.new({}, {
        prompt_title = "Select tmux pane",
        finder = finders.new_table {
            results = options
        },
        sorter = tconfig.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
				local selected_index = action_state.get_selected_entry().index
				vim.g.tmutils_selected_pane = panes[selected_index].pane_id
                actions.close(prompt_bufnr)
            end)
            return true
        end,
    }):find()
end

---Selects a pane using nui
---@param panes TmuxPane[] # Parsed tmux panes.
local function config_selector_nui(panes)
	local Menu = require("nui.menu")

	local options = {}
	for _, pane in ipairs(panes) do
		table.insert(options, Menu.item(("%s %s"):format(pane.pane_id, pane.pane_name)))
	end

	local menu = Menu({
		position = "50%",
		size = {width = 25, height = 5},
		border = {
			style = "single",
			text = {
				top = "Select tmux pane",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
			},
		}, {
			lines = options,
			max_width = 20,
			keymap = {
				focus_next = { "j", "<Down>", "<Tab>" },
				focus_prev = { "k", "<Up>", "<S-Tab>" },
				close = { "<Esc>", "<C-c>" },
				submit = { "<CR>", "<Space>" },
			},
			on_close = function() end,
			on_submit = function(item)
				vim.g.tmutils_selected_pane = vim.split(item.text, ' ')[1]
			end,
		})

	-- mount the component
	menu:mount()
end

---@alias ConfigSelector fun(panes: TmuxPane[]): nil

---@type table<string, ConfigSelector>
local ConfigSelectorProxy = {
	telescope = config_selector_telescope,
	nui = config_selector_nui
}

---Factory that creates selectors.
---@param selector string # Selector to create.
---@return ConfigSelector # Selector function.
M.config_selector_factory = function(selector)
	local fn = ConfigSelectorProxy[selector]
	if fn == nil then
		error(string.format("Invalid selector %s", selector))
	end
	return fn
end

return M
