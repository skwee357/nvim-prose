local M = require("lualine.component"):extend()
local prose = require("nvim-prose")

function M:init(options)
    local user_cond = options.cond
    options.cond = function()
        return prose.is_available() and (user_cond == nil or user_cond())
    end
    M.super.init(self, options)
end

function M:update_status()
    return prose.word_count()
end

return M
