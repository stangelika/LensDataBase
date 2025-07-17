#!/bin/bash

# Test runner script for LensDataBase

set -e

echo "🧪 Running LensDataBase Test Suite"
echo "================================="

# Check if we're on macOS for iOS testing
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📱 Running iOS Tests..."
    
    # Check if Xcode is available
    if ! command -v xcodebuild &> /dev/null; then
        echo "❌ Xcode not found. Please install Xcode to run iOS tests."
        exit 1
    fi
    
    # Run iOS tests
    xcodebuild -scheme LensDataBase \
        -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
        -configuration Debug \
        test \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        -enableCodeCoverage YES \
        | xcpretty
        
    echo "✅ iOS Tests completed"
    
    # Generate coverage report if available
    if command -v xcov &> /dev/null; then
        echo "📊 Generating coverage report..."
        xcov --minimum_coverage_percentage 70
    fi
    
else
    echo "🐧 Running Swift Package Manager Tests..."
    
    # Use the test-compatible Package.swift
    cp Package.test.swift Package.swift
    
    # Run tests with Swift Package Manager
    swift test --enable-code-coverage
    
    echo "✅ Swift Package Manager Tests completed"
    
    # Restore original Package.swift if it exists
    if [ -f Package.swift.backup ]; then
        mv Package.swift.backup Package.swift
    fi
fi

echo ""
echo "🎉 All tests completed successfully!"