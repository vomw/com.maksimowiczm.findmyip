#!/bin/bash

NEW_PKG=$1
OLD_PKG="com.maksimowiczm.findmyip"

if [ -z "$NEW_PKG" ]; then
    echo "Usage: $0 <new.package.id>"
    exit 1
fi

echo "Changing package ID from $OLD_PKG to $NEW_PKG"

# 1. Update build.gradle.kts (applicationId and namespace)
find . -name "build.gradle.kts" -type f -print0 | xargs -0 sed -i "s/$OLD_PKG/$NEW_PKG/g"

# 2. Update AndroidManifest.xml
find . -name "AndroidManifest.xml" -type f -print0 | xargs -0 sed -i "s/$OLD_PKG/$NEW_PKG/g"

# 3. Update Kotlin/Java source files (package declarations and imports)
find . -type f \( -name "*.kt" -o -name "*.java" \) -print0 | xargs -0 sed -i "s/$OLD_PKG/$NEW_PKG/g"

# 4. Rename directory structure to match new package ID
OLD_PATH=$(echo $OLD_PKG | tr '.' '/')
NEW_PATH=$(echo $NEW_PKG | tr '.' '/')

echo "Moving directories from $OLD_PATH to $NEW_PATH"

# Function to move source files for a specific source set
move_sources() {
    local base_dir=$1
    if [ -d "$base_dir/$OLD_PATH" ]; then
        echo "Processing $base_dir"
        mkdir -p "$base_dir/$NEW_PATH"
        mv "$base_dir/$OLD_PATH"/* "$base_dir/$NEW_PATH/"
        # Remove old empty directories recursively up to the 'java' or 'kotlin' root
        rm -rf "$base_dir/$OLD_PATH"
    fi
}

# Find all java and kotlin source roots
find . -type d \( -name "java" -o -name "kotlin" \) | while read source_root; do
    move_sources "$source_root"
done

echo "Package ID transformation complete."
