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
test: build

build: $(LIB)
	@./node_modules/.bin/npub prep lib

prepublish:
	./node_modules/.bin/npub prep

clean:
	@rm -rf "$(LIBDIR)"

# This will fail if there are unstaged changes in the checkout
test-checkout-clean:
	git diff --exit-code

all: setup clean test test-checkout-clean

