local selectors = require("tmutils.selectors")
local F = require("tmutils.functions")

local M = {}


---Entrypoint for pane config.
---@param opts {args: string} # User command options.
---@param conf Config # Plugin config.
M.tmux_config = function(opts, conf)
	if opts.args:len() == 0 then
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
							vim.g.tmutils_selected_pane = vim.split(selected_opt, ' ')[1]
						end
						)
				end,
				stdout_buffered = true
			}
		)
		return
	end

	local args = vim.split(opts.args, ' ')
	if #args > 1 then
		error("Expected maximum 1 argument")
	end
	vim.g.tmutils_selected_pane = args[1]
end

---Creates the default plugin config.
---@param config Config | nil # Main plugin configuration
---@return Config
M.make_default_config = function(config)
	local default_config = {
		selector = {
			selector = selectors.nui_selector
		},
		window = {
			terminal = {
                direction = "vertical",
                size = 20,
				commands = function()
					return {
						("cd %s"):format(vim.fn.getcwd()),
						"clear"
					}
				end
            },
			repls = {}
		}
	}
	if config == nil then
		return default_config
	end
	return config
end

return M
