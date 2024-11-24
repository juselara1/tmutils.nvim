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

return M
