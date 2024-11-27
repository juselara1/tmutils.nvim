local selectors = require("tmutils.selectors")
local F = require("tmutils.functions")
local M = {}

---Entrypoint for pane config.
---@param opts {args: string} # User command options.
---@param config SelectorConfig # Selector configuration.
M.tmux_config = function(opts, config)
	if opts.args:len() == 0 then
		local _ = vim.fn.jobstart(
			"tmux list-panes -a",
			{
				---@param data string[]
				on_stdout = function(_, data, _)
					local matches = F.parse_tmux_panes(data)
					selectors.config_selector_factory(config.selector)(matches)
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

return M
