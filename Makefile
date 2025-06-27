# this_file: Makefile

# Binary name
BINARY_NAME = macdefaultbrowser
# Installation directory
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

# Build configuration
SWIFT_BUILD_FLAGS = -c release --arch arm64 --arch x86_64
SWIFT = swift

# Default target
.PHONY: all
all: build

# Build the binary
.PHONY: build
build:
	$(SWIFT) build $(SWIFT_BUILD_FLAGS)
	cp .build/apple/Products/Release/$(BINARY_NAME) ./$(BINARY_NAME)

# Install the binary
.PHONY: install
install: build
	install -d $(BINDIR)
	install -m 755 $(BINARY_NAME) $(BINDIR)/$(BINARY_NAME)

# Clean build artifacts
.PHONY: clean
clean:
	$(SWIFT) package clean
	rm -rf .build
	rm -f $(BINARY_NAME)

# Uninstall the binary
.PHONY: uninstall
uninstall:
	rm -f $(BINDIR)/$(BINARY_NAME)

# Run tests
.PHONY: test
test:
	$(SWIFT) test

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make          - Build the binary"
	@echo "  make install  - Build and install to $(BINDIR)"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make uninstall - Remove installed binary"
	@echo "  make test     - Run tests"
	@echo "  make help     - Show this help message"