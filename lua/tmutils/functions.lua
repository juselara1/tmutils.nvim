local M = {}

---Removes empty lines from array of strings.
---@param data string[] # Input lines.
---@return string[] # Filtered lines.
M.remove_empty_lines = function (data)
	local clean_data = {}
	for _, line in ipairs(data) do
		if string.len(line) ~= 0 then
			table.insert(clean_data, line)
		end
	end
	return clean_data
end

---Joins multiple lines into a single one.
---@param data string[] Input lines.
---@return string Joined lines.
M.join_lines = function (data)
	local res = ""
	for _, line in ipairs(data) do
		res = res .. line .. '\n'
	end
	return res
end

---Gets all the pattern matches in a text
---@param text string # Input text.
---@param pattern string # Pattern to match.
---@return string[] # Matches.
M.all_matches = function (text, pattern)
	local matches = {}
	local m_sta, m_end = string.find(text, pattern)
	while m_sta ~= nil do
		table.insert(matches, text:sub(m_sta, m_end))
		m_sta, m_end = string.find(text, pattern, m_end)
	end
	return matches
end

---Structured parsed tmux pane
---@alias TmuxPane {pane_id: string, pane_name: string}

---Parses tmux list of panes into a lua table.
---@param stdout string[] # Command's stdout.
---@param single_window? boolean # Defines if tmux command was used on a single window or for all panes (-a).
---@return TmuxPane[] # Parsed tmux panes.
M.parse_tmux_panes = function (stdout, single_window)
	single_window = single_window or false
	local name_pat = single_window and "%d+:" or  "%a+:%d+%.%d+"
	local matches = {}
	for _, line in ipairs(stdout) do
		local id_st, id_en = string.find(line, "%%%d+")
		local na_st, na_en = string.find(line, name_pat)
		if (na_st ~= nil and na_en ~= nil and id_st ~= nil and id_en ~= nil) then
			table.insert(matches, {
				pane_id = line:sub(id_st, id_en),
				pane_name = line:sub(na_st, na_en)
			})
		end
	end
	return matches
end

return M
