all: pr-ready t

t: tests
test: tests
tests:
	@echo "===> Running tests \n" && \
  nvim --headless +"lua require('lua.shared.tests').test()" +"qall"

fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

pr-ready: fmt lint
	echo "===> Preparring PR"
	git commit
