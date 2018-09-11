#!/usr/bin/env bash

# Generate up-to-date test interface
echo "👾 Generate up-to-date test interface"
swift test --generate-linuxmain

# Build
echo "🤖 Build"
docker build -f ./Dockerfile -t s3 .

# Run
echo "🏃‍♀️ Run"
docker run s3
