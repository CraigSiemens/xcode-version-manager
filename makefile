NAME=xcvm
SWIFT_BUILD_FLAGS=--configuration release --disable-sandbox
BINARY=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(NAME)
COMPLETIONS_DIR=.build/completions
MAIN_BRANCH=main

.PHONY: all clean build completions readme push-version

all: build

clean:
	swift package clean

build:
	swift build $(SWIFT_BUILD_FLAGS)

completions: build
	mkdir -p "$(COMPLETIONS_DIR)"
	"$(BINARY)" --generate-completion-script bash > "$(COMPLETIONS_DIR)/bash"
	"$(BINARY)" --generate-completion-script zsh > "$(COMPLETIONS_DIR)/zsh"
	"$(BINARY)" --generate-completion-script fish > "$(COMPLETIONS_DIR)/fish"

readme: build
	perl -i -0pe "s/## \`xcvm help\`\n\`\`\`(.|\n)*?\`\`\`/## \`xcvm help\`\n\`\`\`\n$$("$(BINARY)" help)\n\`\`\`/g" README.md

push-version:
ifneq ($(strip $(shell git status --untracked-files=no --porcelain 2>/dev/null)),)
	$(error git state is not clean)
endif
ifneq ($(strip $(shell git branch --show-current)),$(MAIN_BRANCH))
	$(error not on branch $(MAIN_BRANCH))
endif
	$(eval NEW_VERSION := $(filter-out $@,$(MAKECMDGOALS)))
	echo "let version = \"$(NEW_VERSION)\"" > Sources/XcodeVersionManager/Utilities/Version.swift
	make readme
	git commit -a -m "Release $(NEW_VERSION)"
	git tag -a $(NEW_VERSION) -m "Release $(NEW_VERSION)"
	git push origin $(MAIN_BRANCH)
	git push origin $(NEW_VERSION)
	gh release create $(NEW_VERSION) --generate-notes
%:
	@:
