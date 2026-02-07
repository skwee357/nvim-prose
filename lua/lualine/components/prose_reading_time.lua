local M = require("lualine.component"):extend();
local prose = require('nvim-prose');

function M:init(options)
    options.cond = prose.is_available
    M.super.init(self, options)
end

function M:update_status()
    return prose.reading_time()
end

return M
