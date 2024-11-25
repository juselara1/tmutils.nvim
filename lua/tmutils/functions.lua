local M = {}

---Removes empty lines from array of strings.
---@param data string[]
---@return string[]
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
---@param data string[]
---@return string
M.join_lines = function (data)
	local res = ""
	for _, line in ipairs(data) do
		res = res .. line .. '\n'
	end
	return res
end

---Gets all the pattern matches in a text
---@param text string
---@param pattern string
---@return string[]
M.all_matches = function (text, pattern)
	local matches = {}
	local m_sta, m_end = string.find(text, pattern)
	while m_sta ~= nil do
		table.insert(matches, text:sub(m_sta, m_end))
		m_sta, m_end = string.find(text, pattern, m_end)
	end
	return matches
end

return M
