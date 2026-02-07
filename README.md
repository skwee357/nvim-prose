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
```

## API

The plugin exposes the following method:

- `word_count()` - returns the number of words in a document, with `placeholders.words` appended to it
- `reading_time()` - returns the reading time (in minutes) in a document, with `placeholders.minutes` appended to it
- `is_available()` - return whether `nvim-prose` is available in current file type (based on `filetypes` provided in the configuration)

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
        { "nvim-prose", opts = {} } -- <- Pass custom options if needed
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

## Contributing

If you would like to contribute to this plugin, please feel free to submit a pull-request.

## License

Licensed under MIT license.
See [LICENSE.md](/LICENSE.md) for full license file.
