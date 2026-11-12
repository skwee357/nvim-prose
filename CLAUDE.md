# nvim-prose

A small Neovim plugin that computes the **word count** and **reading time** of the
current buffer, intended for prose filetypes (markdown, asciidoc by default). It is
mostly consumed through two bundled `lualine` components, but the API can be called
directly.

## Layout

- `lua/nvim-prose/init.lua` — the whole plugin. Holds a module-local `config`
  (`wpm`, `filetypes`, `format`) and exposes:
  - `setup(opts)` — deep-merges `opts` into the default config and validates `wpm` and
    `format`. Deprecated `placeholders` are converted to `format` (with a warning).
  - `word_count()` — `vim.fn.wordcount().words` formatted with `format.words`.
  - `reading_time()` — `ceil(words / wpm)` formatted with `format.minutes`.
  - `is_available()` — true when `vim.bo.filetype` is in `config.filetypes`.
  - `is_visual()` — true in `v`/`V`/`CTRL-V`; counts then come from `wordcount().visual_words`
    and bypass the cache, since moving a selection does not bump `b:changedtick`. If
    `visual_words` is missing (e.g. another window's statusline), the cached buffer count is used.
- `lua/lualine/components/prose_word_count.lua`, `prose_reading_time.lua` — lualine
  components; their `cond` combines `prose.is_available` with any user `cond`.
- `spec/` — busted tests run inside Neovim via nlua. `spec/support/lualine/component.lua`
  is a minimal stand-in for lualine's component class, so lualine isn't needed to test.
- `README.md` — user docs and the **source of truth for vimdoc**.
- `doc/` — `doc/nvim-prose.txt` is generated from README.md by the `panvimdoc`
  GitHub Action on push to `main`. Do not edit it by hand.
- `lima.yaml` — the Lima VM definition for the dev environment (Debian 13).
- `.github/workflows/ci.yml` — luacheck, StyLua check and busted (stable Neovim) on
  push to `main` and on pull requests. `panvimdoc.yml` is separate.

## How it works

No autocommands. `word_count()` / `reading_time()` share a per-buffer cache keyed on
`b:changedtick`, so `wordcount()` runs only when the current buffer has changed since
the last call. lualine re-evaluates the components on its refresh cycle, and only
shows them when `is_available()` is true.

## Development

Tools available in the VM: `nvim` (0.10), `luajit`, `lua5.1`, `luarocks`,
`luacheck`, `stylua`, `busted` + `nlua` (in `~/.luarocks`), `rg`, `fdfind`, `make`.

- `make check` — lint, format check and tests (what CI runs)
- `make lint` — `luacheck .` (config in `.luacheckrc`)
- `make format` / `make format-check` — StyLua (config in `.stylua.toml`: 4 spaces,
  double quotes, 120 columns)
- `make test` — busted (config in `.busted`). Tests must reset module state:
  `package.loaded["nvim-prose"] = nil` in `before_each`, since `config` is module-local.

## Conventions

- Keep the plugin dependency-free; lualine is optional and only needed for the
  components.
- Keep the LuaCATS annotations (`---@class`, `---@field`) in `init.lua` and the
  config block in README.md in sync.
- Commit style: conventional prefixes (`feat:`, `fix:`, `docs:`).
