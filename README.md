# nvim-prose

Word count and reading time for the prose you write in Neovim, ready to drop into your statusline.

- Counts words and estimates reading time for the current buffer
- Shows the count for the selected text while in visual mode (`v`, `V`, `CTRL-V`)
- Only active in the filetypes you choose (Markdown and AsciiDoc by default)
- Ships with [lualine](https://github.com/nvim-lualine/lualine.nvim) components, or call the API from any statusline
- Customisable output text, e.g. `1250 words`, `1250字` or `7 min read`
- Lightweight: no dependencies, and the count is cached until the buffer changes

## Requirements

- Neovim 0.10 or later

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "skwee357/nvim-prose", opts = {} }
```

With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'skwee357/nvim-prose'
```

Calling `setup()` is optional; the plugin works with the defaults below. To change them:

```lua
require("nvim-prose").setup({ wpm = 250 })
```

## Usage

### With lualine

`nvim-prose` ships two lualine components, `prose_word_count` and `prose_reading_time`:

```lua
require("lualine").setup({
    sections = {
        lualine_x = { "prose_word_count", "prose_reading_time" },
    },
})
```

With lazy.nvim, you can list `nvim-prose` as a lualine dependency and pass its options there:

```lua
{
    "nvim-lualine/lualine.nvim",
    dependencies = {
        { "skwee357/nvim-prose", opts = {} },
    },
}
```

The components are only shown in the configured `filetypes`. If you give a component its
own `cond`, both have to be true for it to show:

```lua
lualine_x = {
    { "prose_word_count", cond = function() return vim.o.columns > 100 end },
},
```

### With any other statusline

The API returns plain strings, so it works anywhere:

```lua
local prose = require("nvim-prose")

if prose.is_available() then
    print(prose.word_count(), prose.reading_time()) -- 1250 words  7 min
end
```

### Visual selection

While text is selected in visual mode, `word_count()` and `reading_time()` report the
selection instead of the whole buffer, so you can check the length of a single section.
They switch back once you leave visual mode.

## Configuration

These are the defaults:

```lua
require("nvim-prose").setup({
    wpm = 200,
    filetypes = { "markdown", "asciidoc" },
    format = {
        words = "%d words",
        minutes = "%d min",
    },
})
```

| Option           | Type     | Description                                                                                               |
| ---------------- | -------- | --------------------------------------------------------------------------------------------------------- |
| `wpm`            | number   | Reading speed in words per minute, used for `reading_time()`. Must be a positive number.                  |
| `filetypes`      | string[] | Filetypes where `is_available()` is true and the lualine components are shown. Replaces the default list. |
| `format.words`   | string   | Output of `word_count()`. `%d` is replaced with the number of words.                                      |
| `format.minutes` | string   | Output of `reading_time()`. `%d` is replaced with the number of minutes, rounded up.                      |

An invalid `wpm` or `format` value is replaced with its default, with a warning.

### Formatting the output

`format` strings go through `string.format`, so the text can sit on either side of the
number, with or without a space. Use `%%` for a literal `%`.

```lua
format = { words = "%d字", minutes = "约%d分钟" }  -- 1250字  约7分钟
format = { words = "%d", minutes = "%d min read" } -- 1250  7 min read
```

### Deprecated: `placeholders`

Older configs set the suffix with `placeholders`:

```lua
placeholders = { words = "w", minutes = "m" }
```

This still works. It's converted to `format = { words = "%d w", minutes = "%d m" }`, and
`false` or `""` removes the suffix. But it shows a deprecation warning and will be removed
in a future release. If both are set, `format` wins.

## API

| Function         | Returns                                                                 |
| ---------------- | ----------------------------------------------------------------------- |
| `setup(opts)`    | Applies your configuration. Optional.                                   |
| `word_count()`   | Word count of the buffer (or selection), formatted with `format.words`. |
| `reading_time()` | Reading time in minutes, rounded up, formatted with `format.minutes`.   |
| `is_available()` | `true` if the current buffer's filetype is in `filetypes`.              |
| `is_visual()`    | `true` while a visual selection is active (`v`, `V` or `CTRL-V`).       |

## Limitations

- Words are counted the way Neovim's `wordcount()` counts them: anything separated by
  whitespace. Markup such as code blocks, front matter, link URLs and list markers counts
  too, which can inflate the numbers for technical documents.
- Languages written without spaces between words, such as Chinese and Japanese, aren't
  counted correctly yet: a whole sentence counts as one word.

## Contributing

Pull requests are welcome. Run `make check` before submitting; it runs the same lint,
format check and tests as CI:

- `make lint`: [luacheck](https://github.com/lunarmodules/luacheck)
- `make format`: [StyLua](https://github.com/JohnnyMorganz/StyLua)
- `make test`: [busted](https://github.com/lunarmodules/busted) with [nlua](https://github.com/mfussenegger/nlua) (`luarocks --local install busted nlua`)

`doc/nvim-prose.txt` is generated from this README by CI, so edit the README rather than
the help file.

## License

MIT. See [LICENSE.md](LICENSE.md).
