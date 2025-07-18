#!/bin/bash

# Code quality runner script for LensDataBase

set -e

echo "🔍 Running LensDataBase Code Quality Checks"
echo "==========================================="

# Check if we're on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📱 macOS detected - checking for required tools..."
    
    # Install tools if not available
    if ! command -v swiftlint &> /dev/null; then
        echo "Installing SwiftLint..."
        brew install swiftlint
    fi
    
    if ! command -v swiftformat &> /dev/null; then
        echo "Installing SwiftFormat..."
        brew install swiftformat
    fi
    
    echo "✅ All tools available"
else
    echo "🐧 Linux detected - limited tools available"
fi

echo ""
echo "🧹 Running SwiftLint..."
echo "======================"

if command -v swiftlint &> /dev/null; then
    swiftlint --config .swiftlint.yml --reporter summary
    echo "✅ SwiftLint check completed"
else
    echo "⚠️  SwiftLint not available on this platform"
fi

echo ""
echo "🎨 Running SwiftFormat..."
echo "========================"

if command -v swiftformat &> /dev/null; then
    swiftformat --config .swiftformat --lint .
    echo "✅ SwiftFormat check completed"
else
    echo "⚠️  SwiftFormat not available on this platform"
fi

echo ""
echo "🔍 Checking for TODO/FIXME comments..."
echo "======================================"

TODO_COUNT=$(find . -name "*.swift" -exec grep -l "TODO\|FIXME" {} \; 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    echo "Found $TODO_COUNT files with TODO/FIXME comments:"
    find . -name "*.swift" -exec grep -H "TODO\|FIXME" {} \; 2>/dev/null
    echo "⚠️  Consider addressing these comments before release"
else
    echo "✅ No TODO/FIXME comments found"
fi

echo ""
echo "🔒 Running Security Checks..."
echo "============================="

echo "Checking for hardcoded secrets..."
SECRET_COUNT=$(find . -name "*.swift" -exec grep -l "password\|secret\|key\|token" {} \; 2>/dev/null | wc -l)
if [ "$SECRET_COUNT" -gt 0 ]; then
    echo "⚠️  Found $SECRET_COUNT files with potential secrets:"
    find . -name "*.swift" -exec grep -H "password\|secret\|key\|token" {} \; 2>/dev/null
    echo "Please review these findings"
else
    echo "✅ No obvious secrets found"
fi

echo "Checking for force unwrapping..."
FORCE_UNWRAP_COUNT=$(find . -name "*.swift" -exec grep -c "!" {} \; 2>/dev/null | awk '{sum += $1} END {print (sum == "" ? 0 : sum)}')
echo "Force unwrapping instances: $FORCE_UNWRAP_COUNT"
if [ "$FORCE_UNWRAP_COUNT" -gt 50 ]; then
    echo "⚠️  High number of force unwrapping instances - consider using safe unwrapping"
else
    echo "✅ Force unwrapping usage is within acceptable limits"
fi

echo ""
echo "📊 Code Statistics..."
echo "===================="

echo "Swift files: $(find . -name "*.swift" | wc -l)"
echo "Lines of code: $(find . -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')"

PUBLIC_FUNCS=$(find . -name "*.swift" -exec grep -c "public func\|public var\|public class\|public struct" {} \; 2>/dev/null | awk '{sum += $1} END {print (sum == "" ? 0 : sum)}')
DOCUMENTED_FUNCS=$(find . -name "*.swift" -exec grep -B1 "public func\|public var\|public class\|public struct" {} \; 2>/dev/null | grep -c "///" || echo 0)

echo "Public APIs: $PUBLIC_FUNCS"
echo "Documented APIs: $DOCUMENTED_FUNCS"

if [ "$PUBLIC_FUNCS" -gt 0 ]; then
    DOC_COVERAGE=$(echo "scale=2; $DOCUMENTED_FUNCS * 100 / $PUBLIC_FUNCS" | bc -l 2>/dev/null || echo "0")
    echo "Documentation coverage: $DOC_COVERAGE%"
    
    if (( $(echo "$DOC_COVERAGE >= 80" | bc -l 2>/dev/null || echo 0) )); then
        echo "✅ Good documentation coverage"
    else
        echo "⚠️  Consider improving documentation coverage"
    fi
else
    echo "✅ No public APIs to document"
fi

echo ""
echo "🎉 Code quality checks completed!"
echo "Check the output above for any issues that need attention."