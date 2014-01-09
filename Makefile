default: build

COFFEE=node_modules/.bin/coffee

SRCDIR = src
SRC = $(shell find $(SRCDIR) -type f -name '*.coffee' | sort)
LIBDIR = lib
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	$(COFFEE) --js --input "$<" --output "$@" --source-map-file "$@.map"

setup:
	npm install

.PHONY: test
test: build
	@./node_modules/.bin/coffee test/integration_runner.coffee
	@./node_modules/.bin/coffee test/screenshot_integration_runner.coffee

test-only: build
	@./node_modules/.bin/coffee test/integration_runner.coffee

test-all: build
	@BROWSER=phantomjs,firefox,chrome ./node_modules/.bin/coffee test/integration_runner.coffee
	@./node_modules/.bin/coffee test/screenshot_integration_runner.coffee


build: $(LIB)
	@./node_modules/.bin/npub prep lib

clean:
	@rm -rf "$(LIBDIR)"
	@rm -rf test/integration_log
	@rm -rf test/integration_screenshots
	@rm -rf test/screenshot_integration_log
	@rm -rf test/screenshot_integration_screenshots

# This will fail if there are unstaged changes in the checkout
test-checkout-clean:
	git diff --exit-code

all: setup clean test test-checkout-clean
