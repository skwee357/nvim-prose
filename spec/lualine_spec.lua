local function buffer(lines, filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = filetype
end

for _, case in ipairs({
    { "prose_word_count", "2 words" },
    { "prose_reading_time", "1 min" },
}) do
    local name, expected = case[1], case[2]

    describe("lualine component " .. name, function()
        local component

        before_each(function()
            package.loaded["nvim-prose"] = nil
            package.loaded["lualine.components." .. name] = nil
            component = require("lualine.components." .. name)
        end)

        it("renders the status", function()
            buffer({ "one two" }, "markdown")
            assert.equals(expected, component:new({}):update_status())
        end)

        it("is shown only for enabled filetypes", function()
            local c = component:new({})
            buffer({}, "markdown")
            assert.is_true(c.options.cond())
            buffer({}, "lua")
            assert.is_false(c.options.cond())
        end)

        it("combines a user cond with the filetype check", function()
            local allow = false
            local c = component:new({
                cond = function()
                    return allow
                end,
            })
            buffer({}, "markdown")
            assert.is_false(c.options.cond())
            allow = true
            assert.is_true(c.options.cond())
            buffer({}, "lua")
            assert.is_false(c.options.cond())
        end)
    end)
end
