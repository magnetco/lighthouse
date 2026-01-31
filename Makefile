# Lighthouse Build Commands
# Run 'make help' for available commands

.PHONY: help build release clean archive notarize

# Configuration
APP_NAME := Lighthouse
SCHEME := Lighthouse
CONFIGURATION := Release
BUILD_DIR := build
ARCHIVE_PATH := $(BUILD_DIR)/$(APP_NAME).xcarchive
EXPORT_PATH := $(BUILD_DIR)/export

help:
	@echo "Lighthouse Build Commands"
	@echo "========================="
	@echo ""
	@echo "  make build      - Build debug version"
	@echo "  make release    - Build release version"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make archive    - Create release archive"
	@echo "  make open       - Open project in Xcode"
	@echo "  make run        - Build and run debug version"
	@echo ""

build:
	@echo "Building $(APP_NAME) (Debug)..."
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Debug \
		build

release:
	@echo "Building $(APP_NAME) (Release)..."
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Release \
		build

clean:
	@echo "Cleaning build artifacts..."
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		clean
	rm -rf $(BUILD_DIR)
	rm -rf .build

archive:
	@echo "Creating archive for $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		archive

export: archive
	@echo "Exporting app from archive..."
	xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(EXPORT_PATH) \
		-exportOptionsPlist ExportOptions.plist

open:
	@echo "Opening $(APP_NAME).xcodeproj..."
	open $(APP_NAME).xcodeproj

run:
	@echo "Building and running $(APP_NAME)..."
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Debug \
		build
	@open "$(HOME)/Library/Developer/Xcode/DerivedData/$(APP_NAME)-*/Build/Products/Debug/$(APP_NAME).app"

# Version management
version:
	@grep -A1 "MARKETING_VERSION" $(APP_NAME).xcodeproj/project.pbxproj | head -1

# App Store submission helper
appstore-check:
	@echo "Pre-submission checklist:"
	@echo "  [ ] Version number updated"
	@echo "  [ ] Build number incremented"
	@echo "  [ ] CHANGELOG.md updated"
	@echo "  [ ] Screenshots current"
	@echo "  [ ] App Store description reviewed"
	@echo "  [ ] Privacy policy URL valid"
	@echo "  [ ] Support URL valid"
