#!/usr/bin/env bash

# install dependencies
gem install xcpretty
brew install vapor/tap/vapor

# Generate up-to-date test interface
echo "👾 Generate up-to-date test interface"
vapor xcode -y

# Build
echo "🤖 Build"
set -o pipefail && xcodebuild -scheme S3DemoRun clean build | xcpretty

# Run
echo "🏃‍♀️ Test"
set -o pipefail && xcodebuild -scheme S3DemoRun test | xcpretty
