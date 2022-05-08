SOURCE_FILES ?= $(shell find . -type f -name '*.dart' -print)
FLUTTER ?= fvm flutter
TARGET ?= web
DEVICE_ID ?= chrome

# Git
GIT_REVISION ?= $(shell git rev-parse --short HEAD)
GIT_TAG ?= $(shell git describe --tags --abbrev=0 | sed -e s/v//g)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: install-deps
install-deps: ## install dependencies
	fvm install

.PHONY: format-check
format-check: ## check code format
	$(FLUTTER) format $(SOURCE_FILES) --set-exit-if-changed

.PHONY: lint
lint: ## lint
	$(FLUTTER) analyze

.PHONY: test
test: ## run tests
	$(FLUTTER) test

.PHONY: build
build: ## build an app
	$(FLUTTER) build $(TARGET) \
		--dart-define "GIT_TAG=$(GIT_TAG)" \
		--dart-define "GIT_REVISION=$(GIT_REVISION)" \

.PHONY: ci-test
ci-test: install-deps format-check lint test build ## ci test

.PHONY: run
run: ## run an app
	$(FLUTTER) run --device-id $(DEVICE_ID) \
		--dart-define "GIT_TAG=$(GIT_TAG)" \
		--dart-define "GIT_REVISION=$(GIT_REVISION)" \
