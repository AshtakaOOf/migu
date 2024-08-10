#!/bin/bash

METAINFO="../flatpak/com.github.nocrypt.migu.metainfo.xml"

PACKAGE="package.json"

# Get the version from package.json
VERSION=$(awk -F'"' '/"version": ".+"/{ print $4; exit; }' "$PACKAGE")

# Get the date of the last commit
LAST_COMMIT_DATE=$(git log -1 --format=%cd --date=format:'%Y-%m-%d')

# Temporary file for modified XML
TEMP_FILE=$(mktemp)

# Process the XML file
awk -v version="$VERSION" -v date="$LAST_COMMIT_DATE" '
/<releases>/ {
    print $0
    printf "        <release version=\"%s\" date=\"%s\"/>\n", version, date
    next
}
{print}
' "$METAINFO" > "$TEMP_FILE"

# Replace the original file with the modified one
mv "$TEMP_FILE" "$METAINFO"

echo "flatpak metainfo updated to version $VERSION $LAST_COMMIT_DATE."
