NAME=xcvm
SWIFT_BUILD_FLAGS=--configuration release
EXECUTABLE_PATH=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(NAME)

BINARIES_FOLDER=/usr/local/bin

.PHONY: all clean build install uninstall

all: build

clean:
	swift package clean

build:
	swift build $(SWIFT_BUILD_FLAGS)

install: build
	install -d "$(BINARIES_FOLDER)"
	install "$(EXECUTABLE_PATH)" "$(BINARIES_FOLDER)"

uninstall:
	rm -f "$(BINARIES_FOLDER)/$(NAME)"
