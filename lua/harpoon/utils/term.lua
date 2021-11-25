local Job = require("plenary.job")
local harpoon = require("harpoon")
local log = require("harpoon.dev").log

local M = {}

local function get_first_empty_slot()
    log.trace("_get_first_empty_slot()")
    for idx, cmd in pairs(harpoon.get_term_config().cmds) do
        if cmd == "" then
            return idx
        end
    end
    return M.get_length() + 1
end

M.get_os_command_output = function(cmd, cwd)
    if type(cmd) ~= "table" then
        print("Harpoon: [get_os_command_output]: cmd has to be a table")
        return {}
    end
    local command = table.remove(cmd, 1)
    local stderr = {}
    local stdout, ret = Job
        :new({
            command = command,
            args = cmd,
            cwd = cwd,
            on_stderr = function(_, data)
                table.insert(stderr, data)
            end,
        })
        :sync()
    return stdout, ret, stderr
end

M.get_length = function()
    log.trace("_get_length()")
    return table.maxn(harpoon.get_term_config().cmds)
end

M.valid_index = function(idx)
    if idx == nil or idx > M.get_length() or idx <= 0 then
        return false
    end
    return true
end

M.emit_changed = function()
    log.trace("_emit_changed()")
    if harpoon.get_global_settings().save_on_change then
        harpoon.save()
    end
end

M.add_cmd = function(cmd)
    log.trace("add_cmd()")
    local found_idx = get_first_empty_slot()
    harpoon.get_term_config().cmds[found_idx] = cmd
    M.emit_changed()
end

M.rm_cmd = function(idx)
    log.trace("rm_cmd()")
    if not M.valid_index(idx) then
        log.debug("rm_cmd(): no cmd exists for index", idx)
        return
    end
    table.remove(harpoon.get_term_config().cmds, idx)
    M.emit_changed()
end

M.set_cmd_list = function(new_list)
    log.trace("set_cmd_list(): New list:", new_list)
    for k in pairs(harpoon.get_term_config().cmds) do
        harpoon.get_term_config().cmds[k] = nil
    end
    for k, v in pairs(new_list) do
        harpoon.get_term_config().cmds[k] = v
    end
    M.emit_changed()
end

return M
