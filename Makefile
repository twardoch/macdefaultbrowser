# this_file: Makefile

# Binary name
BINARY_NAME = macdefaultbrowser
# Installation directory
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

# Project directory
PROJECT_DIR = macdefaultbrowser
PYTHON_PROJECT_DIR = macdefaultbrowsy

# Directories
BUILD_DIR = $(PROJECT_DIR)/build
DIST_DIR = $(PROJECT_DIR)/dist

# Version detection from git tags
# Try to get version from git describe, fallback to 0.0.1-dev if no tags
GIT_TAG := $(shell git describe --tags --exact-match 2>/dev/null || echo "")
GIT_DESCRIBE := $(shell git describe --tags --always --dirty 2>/dev/null || echo "0.0.1-dev")

# Extract semantic version from git tag (remove 'v' prefix if present)
ifdef GIT_TAG
    VERSION ?= $(patsubst v%,%,$(GIT_TAG))
else
    VERSION ?= $(GIT_DESCRIBE)
endif

# Build configuration
SWIFT_BUILD_FLAGS = -c release --arch arm64 --arch x86_64
SWIFT = swift

# Code signing configuration (optional)
CODESIGN_IDENTITY ?= 
CODESIGN_FLAGS = --force --options runtime --timestamp

# Default target
.PHONY: all
all: build

# Build the binary
.PHONY: build
build: generate-version
	@mkdir -p $(BUILD_DIR)
	$(SWIFT) build --package-path $(PROJECT_DIR) $(SWIFT_BUILD_FLAGS)
	cp $(PROJECT_DIR)/.build/apple/Products/Release/$(BINARY_NAME) $(BUILD_DIR)/$(BINARY_NAME)

# Generate Version.swift from template
.PHONY: generate-version
generate-version:
	@echo "Generating Version.swift with version $(VERSION)"
	@sed -e 's/VERSION_PLACEHOLDER/$(VERSION)/g' \
	     -e 's/GIT_DESCRIBE_PLACEHOLDER/$(GIT_DESCRIBE)/g' \
	     $(PROJECT_DIR)/Sources/macdefaultbrowser/Version.swift.template > $(PROJECT_DIR)/Sources/macdefaultbrowser/Version.swift

# Install the binary
.PHONY: install
install: build
	install -d $(BINDIR)
	install -m 755 $(BUILD_DIR)/$(BINARY_NAME) $(BINDIR)/$(BINARY_NAME)

# Clean build artifacts
.PHONY: clean
clean:
	$(SWIFT) package --package-path $(PROJECT_DIR) clean
	rm -rf $(PROJECT_DIR)/.build
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	rm -f $(PROJECT_DIR)/Sources/macdefaultbrowser/Version.swift

# Uninstall the binary
.PHONY: uninstall
uninstall:
	rm -f $(BINDIR)/$(BINARY_NAME)

# Run tests
.PHONY: test
test:
	$(SWIFT) test --package-path $(PROJECT_DIR)

# Sign the binary (optional, requires CODESIGN_IDENTITY)
.PHONY: sign
sign: build
	@if [ -z "$(CODESIGN_IDENTITY)" ]; then \
		echo "Warning: CODESIGN_IDENTITY not set, skipping code signing"; \
		echo "To sign, set CODESIGN_IDENTITY environment variable or use:"; \
		echo "  make sign CODESIGN_IDENTITY=\"Developer ID Application: Your Name (TEAM_ID)\""; \
	else \
		echo "Signing $(BUILD_DIR)/$(BINARY_NAME) with identity: $(CODESIGN_IDENTITY)"; \
		codesign $(CODESIGN_FLAGS) --sign "$(CODESIGN_IDENTITY)" $(BUILD_DIR)/$(BINARY_NAME); \
		echo "Verifying signature..."; \
		codesign --verify --verbose $(BUILD_DIR)/$(BINARY_NAME); \
	fi

# Create distribution package
.PHONY: dist
dist: build
	@echo "Creating distribution package..."
	@if [ -n "$(CODESIGN_IDENTITY)" ]; then \
		$(MAKE) sign; \
	fi
	@mkdir -p $(DIST_DIR)/pkg_root$(BINDIR)
	@mkdir -p $(DIST_DIR)/scripts
	
	# Copy binary to package root
	cp $(BUILD_DIR)/$(BINARY_NAME) $(DIST_DIR)/pkg_root$(BINDIR)/
	
	# Create postinstall script
	@echo '#!/bin/bash' > $(DIST_DIR)/scripts/postinstall
	@echo 'echo "$(BINARY_NAME) has been installed to $(BINDIR)"' >> $(DIST_DIR)/scripts/postinstall
	@chmod +x $(DIST_DIR)/scripts/postinstall
	
	# Build the package
	pkgbuild --root $(DIST_DIR)/pkg_root \
		--identifier com.github.twardoch.$(BINARY_NAME) \
		--version $(VERSION) \
		--scripts $(DIST_DIR)/scripts \
		--install-location / \
		$(DIST_DIR)/$(BINARY_NAME)-$(VERSION).pkg
	
	# Create DMG
	@mkdir -p $(DIST_DIR)/dmg
	cp $(DIST_DIR)/$(BINARY_NAME)-$(VERSION).pkg $(DIST_DIR)/dmg/
	@echo "Creating DMG..."
	hdiutil create -volname "$(BINARY_NAME) $(VERSION)" \
		-srcfolder $(DIST_DIR)/dmg \
		-ov -format UDZO \
		$(DIST_DIR)/$(BINARY_NAME)-$(VERSION).dmg
	
	# Clean up temporary files
	rm -rf $(DIST_DIR)/pkg_root $(DIST_DIR)/scripts $(DIST_DIR)/dmg
	
	@echo "Distribution package created: $(DIST_DIR)/$(BINARY_NAME)-$(VERSION).dmg"

# Show version info
.PHONY: version
version:
	@echo "Version: $(VERSION)"
	@echo "Git tag: $(GIT_TAG)"
	@echo "Git describe: $(GIT_DESCRIBE)"

# Notarize the binary (requires signing first)
.PHONY: notarize
notarize: sign
	@./scripts/notarize.sh

# --- Python Project Targets ---

.PHONY: py-install
py-install:
	pip install -e $(PYTHON_PROJECT_DIR)

.PHONY: py-test
py-test:
	python -m pytest $(PYTHON_PROJECT_DIR)/tests

.PHONY: py-run
py-run:
	$(PYTHON_PROJECT_DIR)/.venv/bin/macdefaultbrowsy

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make          - Build the binary"
	@echo "  make install  - Build and install to $(BINDIR)"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make uninstall - Remove installed binary"
	@echo "  make test     - Run tests"
	@echo "  make sign     - Sign the binary (requires CODESIGN_IDENTITY)"
	@echo "  make notarize - Notarize the binary (requires Apple ID credentials)"
	@echo "  make dist     - Create distribution package (.pkg and .dmg)"
	@echo "  make version  - Show version information"
	@echo "  --- Python ---"
	@echo "  make py-install - Install Python dependencies"
	@echo "  make py-test    - Run Python tests"
	@echo "  make py-run     - Run the Python version"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  CODESIGN_IDENTITY - Developer ID for code signing (optional)"
	@echo "  VERSION           - Override version detection (optional)"
	@echo "  APPLE_ID          - Apple ID for notarization (optional)"
	@echo "  TEAM_ID           - Team ID for notarization (optional)"
	@echo "  NOTARIZATION_PASSWORD - App-specific password (optional)"