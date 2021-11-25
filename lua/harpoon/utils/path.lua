local Path = require("plenary.path")

local M = {}

M.normalize_path = function(item)
    return Path:new(item):make_relative(vim.loop.cwd())
end

return M
