lua_test_files = $(shell find lua -name "*_test.lua")

all: pr-ready t

t: tests
test: tests
tests:
	@echo "===> Running tests \n" \
  $(foreach t_file,$(lua_test_files), $(shell lua $(t_file) > /dev/null && echo '.' || echo 'F');)

fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

pr-ready: fmt lint
	echo "===> Preparring PR"
	git commit
