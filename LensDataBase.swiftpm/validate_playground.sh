#!/bin/bash

# Swift Playground Compilation Validator for LensDataBase
# This script validates that the project structure is correct for Swift Playgrounds

echo "🎯 Swift Playground Validation"
echo "==============================="
echo

cd "$(dirname "$0")"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

validation_passed=true

print_section() {
    echo -e "${BLUE}📋 $1${NC}"
    echo "$(printf '%.0s-' {1..40})"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    validation_passed=false
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Check Swift Playground Package Structure
print_section "Package Structure"

if [[ -f "Package.swift" ]]; then
    print_success "Package.swift exists"
    
    # Check for required imports
    if grep -q "import AppleProductTypes" Package.swift; then
        print_success "AppleProductTypes import found"
    else
        print_error "Missing AppleProductTypes import - required for Swift Playground"
    fi
    
    if grep -q "\.iOSApplication" Package.swift; then
        print_success "iOS Application product type found"
    else
        print_error "Missing iOS Application product type"
    fi
    
    # Check minimum iOS version
    if grep -q "iOS.*18.0" Package.swift; then
        print_success "iOS 18.0+ deployment target set"
    else
        print_warning "iOS deployment target should be 18.0+"
    fi
else
    print_error "Package.swift not found"
fi

echo

# 2. Check App Entry Point
print_section "App Entry Point"

if [[ -f "MyApp.swift" ]]; then
    print_success "MyApp.swift exists"
    
    if grep -q "@main" MyApp.swift; then
        print_success "@main attribute found"
    else
        print_error "Missing @main attribute in app entry point"
    fi
    
    if grep -q ": App" MyApp.swift; then
        print_success "App protocol conformance found"
    else
        print_error "App entry point should conform to App protocol"
    fi
else
    print_error "MyApp.swift not found"
fi

echo

# 3. Check Resources Structure
print_section "Resources"

if [[ -d "Resources" ]]; then
    print_success "Resources directory exists"
    
    if [[ -f "Resources/CAMERADATA.json" ]]; then
        print_success "CAMERADATA.json found in Resources"
    else
        print_warning "CAMERADATA.json not found in Resources"
    fi
else
    print_warning "Resources directory not found"
fi

if [[ -d "Assets.xcassets" ]]; then
    print_success "Assets.xcassets directory exists"
    
    if [[ -f "Assets.xcassets/AppIcon.appiconset/Contents.json" ]]; then
        print_success "App icon configuration found"
    else
        print_warning "App icon configuration not found"
    fi
else
    print_warning "Assets.xcassets directory not found"
fi

echo

# 4. Check Core Swift Files
print_section "Core Files"

required_files=(
    "MyApp.swift:App entry point"
    "Models.swift:Data models"
    "DataManager.swift:Data management"
    "NetworkService.swift:Network layer"
    "MainTabView.swift:Main navigation"
    "AppTheme.swift:Theme system"
)

for file_desc in "${required_files[@]}"; do
    IFS=':' read -r file desc <<< "$file_desc"
    if [[ -f "$file" ]]; then
        print_success "$file ($desc)"
    else
        print_error "$file missing ($desc)"
    fi
done

echo

# 5. Check for Swift 5.9+ Features
print_section "Swift Version Compatibility"

if grep -r "@available(iOS 18" *.swift >/dev/null 2>&1; then
    print_success "iOS 18 availability checks found"
else
    print_warning "Consider adding iOS 18 availability checks where needed"
fi

if grep -r "async" *.swift >/dev/null 2>&1; then
    print_success "Modern async/await usage found"
else
    print_warning "Consider using async/await for better concurrency"
fi

echo

# 6. Check SwiftUI Structure
print_section "SwiftUI Structure"

view_files=$(find . -name "*View.swift" | wc -l)
if [[ $view_files -gt 5 ]]; then
    print_success "Found $view_files SwiftUI view files"
else
    print_warning "Few SwiftUI view files found ($view_files)"
fi

if grep -r "ObservableObject" *.swift >/dev/null 2>&1; then
    print_success "ObservableObject pattern usage found"
else
    print_warning "Consider using ObservableObject for state management"
fi

echo

# 7. Simulate Basic Swift Playground Checks
print_section "Swift Playground Compatibility"

# Check that there are no standard SPM dependencies that won't work in Playground
if grep -q "dependencies:" Package.swift; then
    dependencies_count=$(grep -A 20 "dependencies:" Package.swift | grep -c "\.package")
    if [[ $dependencies_count -gt 0 ]]; then
        print_warning "External dependencies found - may not work in Swift Playgrounds"
    else
        print_success "No external dependencies (Swift Playground compatible)"
    fi
else
    print_success "No dependencies section (Swift Playground compatible)"
fi

# Check for proper module structure
if grep -q "targets:" Package.swift; then
    if grep -q "executableTarget" Package.swift; then
        print_success "Executable target found (correct for Swift Playground apps)"
    else
        print_warning "Should use executableTarget for Swift Playground apps"
    fi
fi

echo

# 8. Generate validation report
print_section "Validation Summary"

total_swift_files=$(find . -name "*.swift" | wc -l)
total_lines=$(find . -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')

echo "📊 Project Statistics:"
echo "  - Swift files: $total_swift_files"
echo "  - Total lines of code: $total_lines"
echo "  - Package configuration: $(if [[ -f Package.swift ]]; then echo "✅ Present"; else echo "❌ Missing"; fi)"
echo "  - App entry point: $(if [[ -f MyApp.swift ]]; then echo "✅ Present"; else echo "❌ Missing"; fi)"
echo "  - Resources: $(if [[ -d Resources ]]; then echo "✅ Present"; else echo "⚠️ Missing"; fi)"

echo

if [[ "$validation_passed" == true ]]; then
    echo -e "${GREEN}🎉 Swift Playground validation passed!${NC}"
    echo "✅ Project is properly structured for Swift Playgrounds"
    echo "📱 Ready to run on iPad or iPhone with Swift Playgrounds app"
    echo "🖥️ Can also be opened in Xcode for development"
    exit 0
else
    echo -e "${RED}❌ Swift Playground validation failed!${NC}"
    echo "🔧 Please fix the issues above before running in Swift Playgrounds"
    exit 1
fi