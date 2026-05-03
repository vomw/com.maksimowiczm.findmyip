#!/bin/bash

NEW_PKG=$1
OLD_PKG="com.maksimowiczm.findmyip"

if [ -z "$NEW_PKG" ]; then
    echo "Usage: $0 <new.package.id>"
    exit 1
fi

# Escape dots for literal search in sed
ESCAPED_OLD_PKG=$(echo "$OLD_PKG" | sed 's/\./\\./g')

# Handle Kotlin keywords in the new package name (for .kt files)
# Keywords list: https://kotlinlang.org/docs/keyword-reference.html
KEYWORDS="as|break|class|continue|do|else|false|for|fun|if|in|interface|is|null|object|package|return|super|this|throw|true|try|typealias|val|var|when|while"

KOTLIN_NEW_PKG=""
IFS='.' read -ra ADDR <<< "$NEW_PKG"
for segment in "${ADDR[@]}"; do
    if [[ "$segment" =~ ^($KEYWORDS)$ ]]; then
        # Escape keywords with backticks for Kotlin source code
        KOTLIN_NEW_PKG="${KOTLIN_NEW_PKG}\`$segment\`."
    else
        KOTLIN_NEW_PKG="${KOTLIN_NEW_PKG}${segment}."
    fi
done
KOTLIN_NEW_PKG="${KOTLIN_NEW_PKG%.}" # Remove trailing dot

echo "Changing package ID from $OLD_PKG to $NEW_PKG"
if [ "$NEW_PKG" != "$KOTLIN_NEW_PKG" ]; then
    echo "Using Kotlin-escaped package ID in .kt files: $KOTLIN_NEW_PKG"
fi

# 1. Update non-Kotlin files (using plain NEW_PKG)
# We include build.gradle.kts because applicationId and namespace are strings, not source code identifiers
find . -type f \( -name "build.gradle.kts" -o -name "AndroidManifest.xml" -o -name "*.xml" -o -name "*.pro" -o -name "*.json" \) -print0 | xargs -0 sed -i "s/$ESCAPED_OLD_PKG/$NEW_PKG/g"

# 2. Update Kotlin/Java source files
# .kt files need potentially escaped keywords for package declarations and imports
find . -type f -name "*.kt" -print0 | xargs -0 sed -i "s/$ESCAPED_OLD_PKG/$KOTLIN_NEW_PKG/g"
# .java files do not use backticks for keywords
find . -type f -name "*.java" -print0 | xargs -0 sed -i "s/$ESCAPED_OLD_PKG/$NEW_PKG/g"

# 3. Rename source directory structure
OLD_PATH=$(echo "$OLD_PKG" | tr '.' '/')
NEW_PATH=$(echo "$NEW_PKG" | tr '.' '/')

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
# Sort by depth descending to process children before parents
find . -type d -name "*$OLD_PKG*" | sort -r | while read dir; do
    NEW_DIR=$(echo "$dir" | sed "s/$ESCAPED_OLD_PKG/$NEW_PKG/g")
    if [ "$dir" != "$NEW_DIR" ]; then
        echo "Renaming $dir -> $NEW_DIR"
        mkdir -p "$(dirname "$NEW_DIR")"
        mv "$dir"/* "$NEW_DIR/" 2>/dev/null || true
        mv "$dir" "$NEW_DIR" 2>/dev/null || true
    fi
done

echo "Package ID transformation complete."
