#!/bin/bash

NEW_PKG=$1
OLD_PKG="com.maksimowiczm.findmyip"

if [ -z "$NEW_PKG" ]; then
    echo "Usage: $0 <new.package.id>"
    exit 1
fi

echo "Changing package ID from $OLD_PKG to $NEW_PKG"

# 1. Update build.gradle.kts (applicationId and namespace)
find . -name "build.gradle.kts" -exec sed -i "s/$OLD_PKG/$NEW_PKG/g" {} +

# 2. Update AndroidManifest.xml
find . -name "AndroidManifest.xml" -exec sed -i "s/$OLD_PKG/$NEW_PKG/g" {} +

# 3. Update Kotlin/Java source files (package declarations and imports)
find . -name "*.kt" -o -name "*.java" | xargs sed -i "s/$OLD_PKG/$NEW_PKG/g" {} +

# 4. Rename directory structure to match new package ID
# This is crucial for Kotlin/Java source sets
OLD_PATH=$(echo $OLD_PKG | tr '.' '/')
NEW_PATH=$(echo $NEW_PKG | tr '.' '/')

echo "Moving directories from $OLD_PATH to $NEW_PATH"

find . -type d -path "*src/*/java/$OLD_PATH" | while read dir; do
    PARENT=$(echo "$dir" | sed "s|$OLD_PATH$||")
    mkdir -p "$PARENT$NEW_PATH"
    mv "$dir"/* "$PARENT$NEW_PATH/"
    rm -rf "$dir"
done

# Also handle test/androidTest source sets
find . -type d -path "*src/*/kotlin/$OLD_PATH" | while read dir; do
    PARENT=$(echo "$dir" | sed "s|$OLD_PATH$||")
    mkdir -p "$PARENT$NEW_PATH"
    mv "$dir"/* "$PARENT$NEW_PATH/"
    rm -rf "$dir"
done

echo "Package ID transformation complete."
