local M = {}

M.split_string = function(str, delimiter)
    local result = {}

    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end

    return result
end

M.is_white_space = function(str)
    return str:gsub("%s", "") == ""
end

return M
