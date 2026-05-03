#!/bin/bash

NEW_PKG=$1
OLD_PKG="com.maksimowiczm.findmyip"

if [ -z "$NEW_PKG" ]; then
    echo "Usage: $0 <new.package.id>"
    exit 1
fi

echo "Changing package ID from $OLD_PKG to $NEW_PKG"

# 1. Update build files, manifests, ProGuard rules, and XML resources
find . -type f \( -name "build.gradle.kts" -o -name "AndroidManifest.xml" -o -name "*.xml" -o -name "*.pro" -o -name "*.json" \) -print0 | xargs -0 sed -i "s/$OLD_PKG/$NEW_PKG/g"

# 2. Update Kotlin/Java source files (package declarations and imports)
find . -type f \( -name "*.kt" -o -name "*.java" \) -print0 | xargs -0 sed -i "s/$OLD_PKG/$NEW_PKG/g"

# 3. Rename directory structure to match new package ID (for Java/Kotlin sources)
OLD_PATH=$(echo $OLD_PKG | tr '.' '/')
NEW_PATH=$(echo $NEW_PKG | tr '.' '/')

echo "Moving source directories from $OLD_PATH to $NEW_PATH"

find . -type d \( -name "java" -o -name "kotlin" \) | while read source_root; do
    if [ -d "$source_root/$OLD_PATH" ]; then
        echo "Processing $source_root"
        mkdir -p "$source_root/$NEW_PATH"
        cp -r "$source_root/$OLD_PATH"/* "$source_root/$NEW_PATH/"
        rm -rf "$source_root/$OLD_PATH"
    fi
done

# 4. Rename other directories containing the package ID (e.g., Room schemas)
echo "Renaming other directories containing the package ID"
# We sort by depth to ensure we process children before parents or vice versa correctly
find . -type d -name "*$OLD_PKG*" | sort -r | while read dir; do
    NEW_DIR=$(echo "$dir" | sed "s/$OLD_PKG/$NEW_PKG/g")
    echo "Renaming $dir -> $NEW_DIR"
    mkdir -p "$(dirname "$NEW_DIR")"
    mv "$dir"/* "$NEW_DIR/" 2>/dev/null || true
    mv "$dir" "$NEW_DIR" 2>/dev/null || true
done

echo "Package ID transformation complete."
