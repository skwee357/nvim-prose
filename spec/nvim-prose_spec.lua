local prose

local function buffer(lines, filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = filetype or "markdown"
    return buf
end

local function words(n)
    local t = {}
    for i = 1, n do
        t[i] = "word"
    end
    return table.concat(t, " ")
end

describe("nvim-prose", function()
    local notify = vim.notify
    local warnings

    before_each(function()
        package.loaded["nvim-prose"] = nil
        prose = require("nvim-prose")
        warnings = {}
        vim.notify = function(msg, level)
            table.insert(warnings, { msg = msg, level = level })
        end
    end)

    after_each(function()
        vim.notify = notify
    end)

    describe("word_count", function()
        it("counts words with the default suffix", function()
            buffer({ "one two three", "four" })
            assert.equals("4 words", prose.word_count())
        end)

        it("works without calling setup", function()
            buffer({ "one two" })
            assert.equals("2 words", prose.word_count())
        end)

        it("returns 0 for an empty buffer", function()
            buffer({})
            assert.equals("0 words", prose.word_count())
        end)

        it("uses a custom suffix", function()
            prose.setup({ placeholders = { words = "w" } })
            buffer({ "one two" })
            assert.equals("2 w", prose.word_count())
        end)

        it("omits the suffix when it is false or empty", function()
            buffer({ "one two" })
            prose.setup({ placeholders = { words = false } })
            assert.equals("2", prose.word_count())
            prose.setup({ placeholders = { words = "" } })
            assert.equals("2", prose.word_count())
        end)
    end)

    describe("reading_time", function()
        it("rounds up to whole minutes", function()
            buffer({ words(201) })
            assert.equals("2 min", prose.reading_time())
        end)

        it("returns exact minutes on a boundary", function()
            buffer({ words(400) })
            assert.equals("2 min", prose.reading_time())
        end)

        it("returns 0 for an empty buffer", function()
            buffer({})
            assert.equals("0 min", prose.reading_time())
        end)

        it("uses a custom wpm", function()
            prose.setup({ wpm = 100 })
            buffer({ words(250) })
            assert.equals("3 min", prose.reading_time())
        end)

        it("omits the suffix when it is false or empty", function()
            buffer({ "one" })
            prose.setup({ placeholders = { minutes = false } })
            assert.equals("1", prose.reading_time())
            prose.setup({ placeholders = { minutes = "" } })
            assert.equals("1", prose.reading_time())
        end)
    end)

    describe("setup", function()
        it("keeps defaults that are not overridden", function()
            prose.setup({ placeholders = { minutes = "m" } })
            buffer({ "one" })
            assert.equals("1 words", prose.word_count())
            assert.equals("1 m", prose.reading_time())
        end)

        for _, case in ipairs({
            { "zero", 0 },
            { "negative", -5 },
            { "a string", "250" },
            { "NaN", 0 / 0 },
            { "infinite", math.huge },
        }) do
            it("rejects " .. case[1] .. " wpm and falls back to 200", function()
                prose.setup({ wpm = case[2] })
                buffer({ words(201) })
                assert.equals("2 min", prose.reading_time())
                assert.equals(1, #warnings)
                assert.equals(vim.log.levels.WARN, warnings[1].level)
            end)
        end

        it("does not warn for a valid wpm", function()
            prose.setup({ wpm = 250 })
            assert.equals(0, #warnings)
        end)
    end)

    describe("word count cache", function()
        local wordcount = vim.fn.wordcount
        local calls

        before_each(function()
            calls = 0
            vim.fn.wordcount = function()
                calls = calls + 1
                return wordcount()
            end
        end)

        after_each(function()
            vim.fn.wordcount = wordcount
        end)

        it("counts once for an unchanged buffer", function()
            buffer({ "one two" })
            prose.word_count()
            prose.reading_time()
            prose.word_count()
            assert.equals(1, calls)
        end)

        it("recounts after the buffer changes", function()
            local buf = buffer({ "one two" })
            assert.equals("2 words", prose.word_count())
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "one two three" })
            assert.equals("3 words", prose.word_count())
            assert.equals(2, calls)
        end)

        it("keeps a separate count per buffer", function()
            local a = buffer({ "one" })
            local b = buffer({ "one two" })
            vim.api.nvim_set_current_buf(a)
            assert.equals("1 words", prose.word_count())
            vim.api.nvim_set_current_buf(b)
            assert.equals("2 words", prose.word_count())
            vim.api.nvim_set_current_buf(a)
            assert.equals("1 words", prose.word_count())
            assert.equals(2, calls)
        end)
    end)

    describe("visual selection", function()
        local result

        local function in_visual(keys)
            result = nil
            _G.__prose_capture = function()
                result = {
                    words = prose.word_count(),
                    minutes = prose.reading_time(),
                    visual = prose.is_visual(),
                }
            end
            local feed = "<Esc>gg" .. keys .. "<Cmd>lua __prose_capture()<CR><Esc>"
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feed, true, false, true), "x", false)
            _G.__prose_capture = nil
            return result
        end

        before_each(function()
            buffer({ "one two three", "four five", words(400) })
        end)

        it("counts the selected lines in visual line mode", function()
            local r = in_visual("Vj")
            assert.is_true(r.visual)
            assert.equals("5 words", r.words)
            assert.equals("1 min", r.minutes)
        end)

        it("counts the selection in charwise visual mode", function()
            assert.equals("2 words", in_visual("vw").words)
        end)

        it("counts the selection in blockwise visual mode", function()
            assert.equals("2 words", in_visual("<C-v>jl").words)
        end)

        it("uses the selection for reading time", function()
            assert.equals("2 min", in_visual("jjV").minutes)
        end)

        it("returns to the whole buffer after leaving visual mode", function()
            in_visual("Vj")
            assert.is_false(prose.is_visual())
            assert.equals("405 words", prose.word_count())
            assert.equals("3 min", prose.reading_time())
        end)

        it("does not overwrite the cached buffer count", function()
            assert.equals("405 words", prose.word_count())
            in_visual("Vj")
            assert.equals("405 words", prose.word_count())
        end)

        it("falls back to the buffer count when there is no selection count", function()
            local wordcount = vim.fn.wordcount
            vim.fn.wordcount = function()
                local wc = wordcount()
                wc.visual_words = nil
                return wc
            end
            local r = in_visual("Vj")
            vim.fn.wordcount = wordcount
            assert.is_true(r.visual)
            assert.equals("405 words", r.words)
            assert.equals("3 min", r.minutes)
        end)
    end)

    describe("is_available", function()
        it("is true for default filetypes", function()
            buffer({}, "markdown")
            assert.is_true(prose.is_available())
            buffer({}, "asciidoc")
            assert.is_true(prose.is_available())
        end)

        it("is false for other filetypes", function()
            buffer({}, "lua")
            assert.is_false(prose.is_available())
        end)

        it("replaces the default filetypes", function()
            prose.setup({ filetypes = { "text" } })
            buffer({}, "text")
            assert.is_true(prose.is_available())
            buffer({}, "markdown")
            assert.is_false(prose.is_available())
        end)

        it("is false when filetypes is empty", function()
            prose.setup({ filetypes = {} })
            buffer({}, "markdown")
            assert.is_false(prose.is_available())
        end)
    end)
end)
