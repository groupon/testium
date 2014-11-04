default: build

COFFEE=node_modules/.bin/coffee --js

SRCDIR = src
SRC = $(shell find $(SRCDIR) -type f -name '*.coffee' | sort)
LIBDIR = lib
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	$(COFFEE) <"$<" >"$@"

setup:
	npm install

.PHONY: test
test: test-unit test-integration test-screenshot

test-integration: build
	@echo "# Integration Tests #"
	@./node_modules/.bin/coffee test/integration_runner.coffee
	@echo ""
	@echo ""

test-screenshot: build
	@echo "# Automatic Screenshot Tests #"
	@./node_modules/.bin/coffee test/screenshot_integration_runner.coffee
	@echo ""
	@echo ""

test-unit: build
	@echo "# Unit Tests #"
	@./node_modules/.bin/mocha --compilers coffee:coffee-script-redux/register --recursive test/unit
	@echo ""
	@echo ""

test-all: build
	@BROWSER=phantomjs,firefox,chrome make test-integration
	@make test-screenshot
	@make test-unit

build: $(LIB)
	@./node_modules/.bin/npub prep src

force-update:
	@./cli.sh --force-update

prepublish:
	./node_modules/.bin/npub prep

clean:
	@rm -rf "$(LIBDIR)"
	@rm -rf test/integration_log
	@rm -rf test/integration_screenshots
	@rm -rf test/screenshot_integration_log
	@rm -rf test/screenshot_integration_screenshots

# This will fail if there are unstaged changes in the checkout
test-checkout-clean:
	git diff --exit-code

all: setup force-update clean test test-checkout-clean
