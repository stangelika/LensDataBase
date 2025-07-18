#!/bin/bash

# Script to check for potential scope issues in Swift files
# This helps prevent "cannot find X in scope" errors

echo "🔍 Checking for potential component scope issues..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

# Check for duplicate struct names
echo "📋 Checking for duplicate struct definitions..."
STRUCT_NAMES=$(find . -name "*.swift" -exec grep -h "^struct " {} \; | sed 's/struct \([^<: ]*\).*/\1/' | sort)
DUPLICATE_STRUCTS=$(echo "$STRUCT_NAMES" | uniq -d)

if [ -n "$DUPLICATE_STRUCTS" ]; then
    echo -e "${RED}⚠️  Found duplicate struct names:${NC}"
    echo "$DUPLICATE_STRUCTS" | while read -r name; do
        echo -e "${YELLOW}  - $name${NC}"
        grep -rn "^struct $name" . --include="*.swift" | head -5
        echo
    done
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ No duplicate struct names found${NC}"
fi

# Check for component usage without definition in same file
echo "🔗 Checking for component usage patterns..."
COMPONENT_USAGE=$(find . -name "*.swift" -exec grep -l "Card\|Chip\|Component" {} \;)

for file in $COMPONENT_USAGE; do
    # Check if file uses components not defined in it
    USED_COMPONENTS=$(grep -o "[A-Z][a-zA-Z]*Card\|[A-Z][a-zA-Z]*Chip" "$file" | sort -u)
    DEFINED_COMPONENTS=$(grep -o "^struct [A-Z][a-zA-Z]*Card\|^struct [A-Z][a-zA-Z]*Chip" "$file" | sed 's/^struct //' | sort -u)
    
    for component in $USED_COMPONENTS; do
        if ! echo "$DEFINED_COMPONENTS" | grep -q "$component"; then
            # Check if component is defined in Components directory
            if ! find ./Components -name "*.swift" -exec grep -l "struct $component" {} \; | head -1 | grep -q .; then
                echo -e "${YELLOW}⚠️  $file uses $component but it's not defined locally or in Components/${NC}"
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        fi
    done
done

# Check for missing imports
echo "📦 Checking for missing imports..."
SWIFTUI_FILES=$(find . -name "*.swift" -exec grep -l "View\|Button\|Text\|VStack\|HStack" {} \;)

for file in $SWIFTUI_FILES; do
    if ! grep -q "import SwiftUI" "$file"; then
        echo -e "${RED}⚠️  $file uses SwiftUI but doesn't import it${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

# Check for components in wrong directories
echo "📁 Checking component organization..."
ROOT_COMPONENTS=$(find . -maxdepth 1 -name "*.swift" -exec grep -l "^struct.*Card\|^struct.*Chip\|^struct.*Component" {} \;)

if [ -n "$ROOT_COMPONENTS" ]; then
    echo -e "${YELLOW}⚠️  Found component definitions in root directory (should be in Components/):${NC}"
    echo "$ROOT_COMPONENTS" | while read -r file; do
        grep -n "^struct.*Card\|^struct.*Chip\|^struct.*Component" "$file" | head -3
    done
fi

# Summary
echo
echo "📊 Summary:"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No scope issues found!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Found $ISSUES_FOUND potential scope issues${NC}"
    echo "💡 Consider organizing components in the Components/ directory"
    echo "💡 Ensure all components are properly imported where used"
    echo "💡 Avoid duplicate component names"
    exit 1
fi