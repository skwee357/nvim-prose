# nvim-prose

A simple plugin to display reading time and word count.

## Installing

Using `plug`:

```
Plug 'skwee357/nvim-prose'
```

Using `lazy.nvim`:

```lua
return {"skwee357/nvim-prose"}
```

## Configuration

Default config is available below:

```lua
---@class nvim-prose.Config
---@field wpm? number Words per minute, must be a positive number (default: 200)
---@field filetypes? string[] Filetypes to enable (default: { "markdown", "asciidoc" })
---@field format? nvim-prose.Format

---@class nvim-prose.Format
---@field words? string Format for word count, `%d` is the number (default: "%d words")
---@field minutes? string Format for reading time, `%d` is the number (default: "%d min")

---@type nvim-prose.Config
local config = {
    wpm = 200.0,
    filetypes = { "markdown", "asciidoc" },
    format = {
        words = "%d words",
        minutes = "%d min",
    },
}
```

`format` strings are passed to `string.format` with the number, so the text can go on
either side of it, with or without a space. Use `%%` for a literal `%`:

```lua
format = { words = "%d字", minutes = "约%d分钟" }  -- 120字 · 约3分钟
format = { words = "%d", minutes = "%d min read" } -- 120 · 3 min read
```

### Deprecated: `placeholders`

`placeholders = { words = "w", minutes = "m" }` still works (it is converted to
`format = { words = "%d w", minutes = "%d m" }`; `false` or `""` drops the suffix), but
it shows a deprecation warning and will be removed in a future release. If both are set,
`format` wins.

## API

The plugin exposes the following method:

- `word_count()` - returns the number of words in a document, formatted with `format.words`
- `reading_time()` - returns the reading time (in minutes) in a document, formatted with `format.minutes`
- `is_available()` - return whether `nvim-prose` is available in current file type (based on `filetypes` provided in the configuration)
- `is_visual()` - return whether a visual selection is active (`v`, `V` or `CTRL-V`)

While a visual selection is active, `word_count()` and `reading_time()` report the selected text instead of the whole buffer.

## Usage

### Direct usage

After installing and configuring the plugin, you can use it directly in any place you desire.

```lua
local prose = require("nvim-prose")
print(prose.word_count())
```

### With `lualine`

If you use `lualine`, you can require `nvim-prose` as a dependency to `lualine` (using `lazy.nvim`)

```lua
return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        { "skwee357/nvim-prose", opts = {} } -- <- Pass custom options if needed
    },
}
```

`nvim-prose` ships with two `lualine` components:

- `prose_word_count`
- `prose_reading_time`

You can use them with your `lualine` setup:

```lua
require 'lualine'.setup {
    ...
    sections = {
        ...
        lualine_x = {
                { "prose_word_count" },
                { "prose_reading_time" },
            },
    },
    ...
}
```

Both components are only shown in the configured `filetypes`. If you pass your own
`cond`, it is combined with that check (the component shows only when both are true):

```lua
lualine_x = {
    { "prose_word_count", cond = function() return vim.o.columns > 100 end },
},
```

## Contributing

If you would like to contribute to this plugin, please feel free to submit a pull-request.

## License

Licensed under MIT license.
See [LICENSE.md](/LICENSE.md) for full license file.
