local M = {}

---@class nvim-prose.Config
---@field wpm? number Words per minute (default: 200)
---@field filetypes? string[] Filetypes to enable (default: { "markdown", "asciidoc" })
---@field placeholders? nvim-prose.Placeholders

---@class nvim-prose.Placeholders
---@field words? string Placeholder for word count (default: "words")
---@field minutes? string Placeholder for reading time (default: "min")

---@type nvim-prose.Config
local config = {
    wpm = 200.0,
    filetypes = { 'markdown', 'asciidoc' },
    placeholders = {
        words = 'words',
        minutes = 'min'
    }
}

---@param opts? nvim-prose.Config
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

---@return string
function M.word_count()
    local words = tostring(vim.fn.wordcount().words)

    if config.placeholders and config.placeholders.words then
        return words .. ' ' .. config.placeholders.words
    end
    return words
end

---@return string
function M.reading_time()
    local rt = tostring(math.ceil(vim.fn.wordcount().words / config.wpm))

    if config.placeholders and config.placeholders.minutes then
        return rt .. ' ' .. config.placeholders.minutes
    end
    return rt
end

---@return boolean
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
