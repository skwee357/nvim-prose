local M = {}

---@class nvim-prose.Config
---@field wpm? number Words per minute, must be a positive number (default: 200)
---@field filetypes? string[] Filetypes to enable (default: { "markdown", "asciidoc" })
---@field format? nvim-prose.Format
---@field placeholders? nvim-prose.Placeholders Deprecated, use `format`

---@class nvim-prose.Format
---@field words? string Format for word count, `%d` is the number (default: "%d words")
---@field minutes? string Format for reading time, `%d` is the number (default: "%d min")

---@class nvim-prose.Placeholders
---@field words? string|false
---@field minutes? string|false

local DEFAULT_WPM = 200.0
local DEFAULT_FORMAT = { words = "%d words", minutes = "%d min" }

---@type nvim-prose.Config
local config = {
    wpm = DEFAULT_WPM,
    filetypes = { "markdown", "asciidoc" },
    format = vim.deepcopy(DEFAULT_FORMAT),
}

---@type table<integer, { tick: integer, words: integer }>
local cache = {}

---@param msg string
local function warn(msg)
    vim.notify("nvim-prose: " .. msg, vim.log.levels.WARN)
end

---@param placeholder string|false
---@return string
local function placeholder_to_format(placeholder)
    if not placeholder or placeholder == "" then
        return "%d"
    end
    return "%d " .. tostring(placeholder):gsub("%%", "%%%%")
end

---@param opts nvim-prose.Config
---@return nvim-prose.Config
local function migrate_placeholders(opts)
    local placeholders = opts.placeholders
    opts.placeholders = nil
    if placeholders == nil then
        return opts
    end

    warn("`placeholders` is deprecated and will be removed in a future release, use `format` instead")
    if type(placeholders) ~= "table" then
        return opts
    end

    local format = {}
    for key in pairs(DEFAULT_FORMAT) do
        if placeholders[key] ~= nil then
            format[key] = placeholder_to_format(placeholders[key])
        end
    end
    opts.format = vim.tbl_extend("force", format, opts.format or {})
    return opts
end

---@param opts? nvim-prose.Config
function M.setup(opts)
    opts = migrate_placeholders(vim.deepcopy(opts or {}))
    config = vim.tbl_deep_extend("force", config, opts)
    cache = {}

    local wpm = config.wpm
    if type(wpm) ~= "number" or wpm <= 0 or wpm ~= wpm or wpm == math.huge then
        warn(("invalid wpm %s, must be a positive number; using %d"):format(vim.inspect(wpm), DEFAULT_WPM))
        config.wpm = DEFAULT_WPM
    end

    if type(config.format) ~= "table" then
        config.format = {}
    end
    for key, default in pairs(DEFAULT_FORMAT) do
        local fmt = config.format[key]
        if type(fmt) ~= "string" or not pcall(string.format, fmt, 1) then
            warn(("invalid format.%s %s; using %s"):format(key, vim.inspect(fmt), vim.inspect(default)))
            config.format[key] = default
        end
    end
end

local VISUAL_MODES = { v = true, V = true, ["\22"] = true }

---@return boolean
function M.is_visual()
    return VISUAL_MODES[vim.api.nvim_get_mode().mode:sub(1, 1)] == true
end

---@return integer
local function count_words()
    if M.is_visual() then
        local selected = vim.fn.wordcount().visual_words
        if selected then
            return selected
        end
    end

    local buf = vim.api.nvim_get_current_buf()
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    local entry = cache[buf]
    if not entry or entry.tick ~= tick then
        entry = { tick = tick, words = vim.fn.wordcount().words }
        cache[buf] = entry
    end
    return entry.words
end

---@return string
function M.word_count()
    return config.format.words:format(count_words())
end

---@return string
function M.reading_time()
    return config.format.minutes:format(math.ceil(count_words() / config.wpm))
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
