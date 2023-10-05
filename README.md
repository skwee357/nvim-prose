# nvim-prose

A simple plugin to display reading time and word count.

## Installing

Using `plug`:

```
Plug 'skwee357/nvim-prose'
```

## Usage

Call `setup` with the config you want to pass. The default config is shown below

```lua
require('nvim-prose').setup {
    wpm = 200.0,
    filetypes = { 'markdown', 'asciidoc' },
    placeholders = {
        words = 'words',
        minutes = 'min'
    }
}
```

After than, you can use `nvim-prose` in any location you want (e.g. your status line). It exposes 3 methods:

- `word_count()` - return the number of words in the document
- `reading_time()` - return the reading time (in minutes) of the current document
- `is_available()` - returns whether `nvim-prose` is supported in the current filetype (based on `filetypes` provided in the config)

## To do

- [] Add support for `lualine` (via `lualine` extensions)
- [] Generate proper docs
