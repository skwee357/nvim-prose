local M = {}

---@class nvim-prose.Config
---@field wpm? number Words per minute, must be a positive number (default: 200)
---@field filetypes? string[] Filetypes to enable (default: { "markdown", "asciidoc" })
---@field placeholders? nvim-prose.Placeholders

---@class nvim-prose.Placeholders
---@field words? string|false Suffix for word count, `false` or `""` to disable (default: "words")
---@field minutes? string|false Suffix for reading time, `false` or `""` to disable (default: "min")

local DEFAULT_WPM = 200.0

---@type nvim-prose.Config
local config = {
    wpm = DEFAULT_WPM,
    filetypes = { 'markdown', 'asciidoc' },
    placeholders = {
        words = 'words',
        minutes = 'min'
    }
}

---@param opts? nvim-prose.Config
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})

    local wpm = config.wpm
    if type(wpm) ~= 'number' or wpm <= 0 or wpm ~= wpm or wpm == math.huge then
        vim.notify(
            ('nvim-prose: invalid wpm %s, must be a positive number; using %d'):format(vim.inspect(wpm), DEFAULT_WPM),
            vim.log.levels.WARN
        )
        config.wpm = DEFAULT_WPM
    end
end

---@param value string
---@param suffix? string|false
---@return string
local function with_suffix(value, suffix)
    if suffix and suffix ~= '' then
        return value .. ' ' .. suffix
    end
    return value
end

---@return string
function M.word_count()
    local words = tostring(vim.fn.wordcount().words)
    return with_suffix(words, config.placeholders and config.placeholders.words)
end

---@return string
function M.reading_time()
    local rt = tostring(math.ceil(vim.fn.wordcount().words / config.wpm))
    return with_suffix(rt, config.placeholders and config.placeholders.minutes)
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
