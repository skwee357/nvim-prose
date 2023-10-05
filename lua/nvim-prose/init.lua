local M = {}

local config = {
    wpm = 200.0,
    filetypes = { 'markdown', 'asciidoc' },
    placeholders = {
        words = 'words',
        minutes = 'min'
    }
}

function M.setup(opts)
    opts = opts or {}

    if opts.wpm ~= nil then
        config.wpm = opts.wpm
    end

    if opts.filetypes ~= nil then
        config.filetypes = opts.filetypes
    end

    if opts.placeholders ~= nil then
        config.placeholders = opts.placeholders
    end
end

function M.word_count()
    local words = tostring(vim.fn.wordcount().words)

    if config.placeholders and config.placeholders.words then
        return words .. ' ' .. config.placeholders.words
    end
    return words
end

function M.reading_time()
    local rt = tostring(math.ceil(vim.fn.wordcount().words / config.wpm))

    if config.placeholders and config.placeholders.minutes then
        return rt .. ' ' .. config.placeholders.minutes
    end
    return rt
end

function M.is_available()
    if config.filetypes == nil then
        return false
    end

    for _, val in ipairs(config.filetypes) do
        if val == vim.bo.filetype then
            return true
        end
    end

    return false
end

return M
