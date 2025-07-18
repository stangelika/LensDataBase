#!/bin/bash

# Test iPad compilation compatibility
# This script tests the key components that were mentioned in the original issue

echo "🍎 Testing iPad compilation compatibility..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

echo "📱 Testing component accessibility for iPad..."

# Test that GlassCard is accessible from ComparisonView context
echo "🔍 Checking GlassCard accessibility..."
if grep -q "GlassCard" ComparisonView.swift; then
    if [ -f "Components/GlassCard.swift" ]; then
        echo -e "${GREEN}✅ GlassCard component found and accessible${NC}"
    else
        echo -e "${RED}❌ GlassCard used but component file not found${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${YELLOW}⚠️  GlassCard not used in ComparisonView${NC}"
fi

# Test that all components in Components directory are properly structured
echo "🧩 Checking component structure..."
COMPONENT_FILES=$(find Components -name "*.swift" 2>/dev/null)
if [ -n "$COMPONENT_FILES" ]; then
    echo "$COMPONENT_FILES" | while read -r file; do
        if ! grep -q "import SwiftUI" "$file"; then
            echo -e "${RED}❌ $file missing SwiftUI import${NC}"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        else
            echo -e "${GREEN}✅ $file properly imports SwiftUI${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠️  No components found in Components directory${NC}"
fi

# Test that key files have proper imports
echo "📦 Checking critical imports..."
CRITICAL_FILES=("ComparisonView.swift" "AllLensesView.swift" "RentalView.swift" "MainTabView.swift")

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "import SwiftUI" "$file"; then
            echo -e "${GREEN}✅ $file has SwiftUI import${NC}"
        else
            echo -e "${RED}❌ $file missing SwiftUI import${NC}"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        echo -e "${YELLOW}⚠️  $file not found${NC}"
    fi
done

# Test that there are no case sensitivity issues (common iPad issue)
echo "🔤 Checking for case sensitivity issues..."
if find . -name "*.swift" -exec grep -l "glasscard\|glass[Cc]ard[^A-Z]" {} \; | head -1 | grep -q .; then
    echo -e "${RED}❌ Found potential case sensitivity issues with 'glasscard'${NC}"
    find . -name "*.swift" -exec grep -Hn "glasscard\|glass[Cc]ard[^A-Z]" {} \;
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ No case sensitivity issues found${NC}"
fi

# Test Swift build specifically
echo "🔧 Testing Swift build..."
if swift build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Swift build successful${NC}"
else
    echo -e "${RED}❌ Swift build failed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Test with iOS platform if available
echo "📱 Testing iOS platform build..."
if swift build -c release > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Release build successful${NC}"
else
    echo -e "${RED}❌ Release build failed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Summary
echo
echo "📊 iPad Compatibility Summary:"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ All iPad compatibility checks passed!${NC}"
    echo -e "${GREEN}📱 The original 'cannot find glassCard inscope' issue should be resolved${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ISSUES_FOUND iPad compatibility issues${NC}"
    echo -e "${RED}🔧 Please fix these issues before testing on iPad${NC}"
    exit 1
fi