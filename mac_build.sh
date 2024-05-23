#!/bin/bash

# Set the output directory for the DMG file
output_dir="/path/to/output/directory"

# Set the name of the DMG file
dmg_name="YourAppName.dmg"

# Get the directory of the script (assuming the script is in the project directory)
project_dir="$(cd "$(dirname "$0")" && pwd)"

# Build the Flutter project for macOS
flutter build macos

# Create a temporary directory for packaging
temp_dir=$(mktemp -d)

# Copy the built app to the temporary directory
app_name="$(ls build/macos/Build/Products/Release/ | grep .app)"
cp -R "build/macos/Build/Products/Release/$app_name" "$temp_dir/"

# Create the DMG file
hdiutil create -srcfolder "$temp_dir" -volname "$app_name" -fs HFS+ -format UDZO "$output_dir/$dmg_name"

# Clean up the temporary directory
rm -rf "$temp_dir"

echo "DMG file created: $output_dir/$dmg_name"