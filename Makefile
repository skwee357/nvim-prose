export PATH := $(HOME)/.luarocks/bin:$(PATH)

.PHONY: check lint format format-check test

check: lint format-check test

lint:
	luacheck .

format:
	stylua .

format-check:
	stylua --check .

test:
	eval "$$(luarocks --lua-version=5.1 --local path)" && busted </dev/null
