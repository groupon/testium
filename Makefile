default: build

setup:
	npm install

.PHONY: test
test: test-unit test-screenshot test-missing-selenium test-start-timeout test-no-app test-integration

test-integration: build
	@echo "# Integration Tests #"
	@./node_modules/.bin/mocha test/integration
	@echo ""
	@echo ""

test-screenshot: build
	@echo "# Automatic Screenshot Tests #"
	@./node_modules/.bin/mocha test/screenshots.test.coffee
	@echo ""
	@echo ""

test-start-timeout: build
	@echo "# Start Timeout Tests #"
	@./node_modules/.bin/mocha test/start_timeout.test.coffee
	@echo ""
	@echo ""

test-missing-selenium: build
	@echo "# Missing Selenium Tests #"
	@./node_modules/.bin/mocha test/missing_selenium.test.coffee
	@echo ""
	@echo ""

test-no-app: build
	@echo "# No App Tests #"
	@./node_modules/.bin/mocha test/no_app.test.coffee
	@echo ""
	@echo ""

test-unit: build
	@echo "# Unit Tests #"
	@./node_modules/.bin/mocha test/unit
	@echo ""
	@echo ""

download-selenium:
	./cli.js --download-selenium

firefox: build download-selenium
	@testium_browser=firefox make test-integration

chrome: build download-selenium
	@testium_browser=chrome make test-integration

phantomjs: build
	@testium_browser=phantomjs make test-integration

test-integration-all: phantomjs firefox chrome

build:
	@./node_modules/.bin/coffee -cbo lib src
	@./node_modules/.bin/npub prep src

watch:
	@./node_modules/.bin/coffee -cwbo lib src

force-update:
	@./cli.js --force-update

prepublish:
	./node_modules/.bin/npub prep

clean:
	@rm -rf lib
	@rm -rf bin/chromedriver bin/selenium.jar
	@rm -rf test/integration_log
	@rm -rf test/screenshot_integration_log

# This will fail if there are unstaged changes in the checkout
test-checkout-clean:
	git diff --exit-code

all: setup clean build force-update test test-checkout-clean
