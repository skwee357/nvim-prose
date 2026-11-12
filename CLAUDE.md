# nvim-prose

A small Neovim plugin that computes the **word count** and **reading time** of the
current buffer, intended for prose filetypes (markdown, asciidoc by default). It is
mostly consumed through two bundled `lualine` components, but the API can be called
directly.

## Layout

- `lua/nvim-prose/init.lua` — the whole plugin. Holds a module-local `config`
  (`wpm`, `filetypes`, `placeholders`) and exposes:
  - `setup(opts)` — deep-merges `opts` into the default config.
  - `word_count()` — `vim.fn.wordcount().words` + optional `placeholders.words` suffix.
  - `reading_time()` — `ceil(words / wpm)` + optional `placeholders.minutes` suffix.
  - `is_available()` — true when `vim.bo.filetype` is in `config.filetypes`.
- `lua/lualine/components/prose_word_count.lua`, `prose_reading_time.lua` — lualine
  components; they set `cond = prose.is_available` and return the API strings.
- `README.md` — user docs and the **source of truth for vimdoc**.
- `doc/` — `doc/nvim-prose.txt` is generated from README.md by the `panvimdoc`
  GitHub Action on push to `main`. Do not edit it by hand.
- `lima.yaml` — the Lima VM definition for the dev environment (Debian 13).

## How it works

No autocommands or caching: every call to `word_count()` / `reading_time()` asks
Neovim for `wordcount()` on the current buffer. lualine re-evaluates the components
on its refresh cycle, and only shows them when `is_available()` is true.

## Development

Tools available in the VM: `nvim` (0.10), `luajit`, `lua5.1`, `luarocks`,
`luacheck`, `stylua`, `rg`, `fdfind`, `make`.

- Lint: `luacheck lua/ --globals vim`
- Format: `stylua lua/` (no `stylua.toml` yet; existing code uses 4-space indents
  and single quotes in most places — check the diff before committing a reformat)
- Smoke test headless (load from the repo, no user config):
  ```sh
  nvim --headless -u NONE --cmd 'set rtp+=.' \
    -c 'filetype on' -c 'e some.md' \
    -c 'lua local p=require("nvim-prose"); p.setup({}); print(p.word_count(), p.reading_time(), p.is_available())' \
    -c 'qa!'
  ```
  `-u NONE` disables filetype detection, so enable it (`filetype on`) or
  `set ft=markdown` before testing `is_available()`.

## Conventions

- Keep the plugin dependency-free; lualine is optional and only needed for the
  components.
- Keep the LuaCATS annotations (`---@class`, `---@field`) in `init.lua` and the
  config block in README.md in sync.
- Commit style: conventional prefixes (`feat:`, `fix:`, `docs:`).
