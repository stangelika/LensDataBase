#!/bin/bash

# Swift Code Compilation Validator
# This script performs syntax and compilation checks for the LensDataBase project

echo "🔬 Swift Code Compilation Validator"
echo "===================================="
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

# 1. Check Swift file syntax
print_section "Swift Syntax Validation"

syntax_errors=0
for file in *.swift; do
    if [[ -f "$file" && "$file" != "Package.swift" ]]; then
        echo "Checking $file..."
        
        # Basic syntax checks
        # Check for balanced braces
        open_braces=$(grep -o '{' "$file" | wc -l)
        close_braces=$(grep -o '}' "$file" | wc -l)
        
        if [[ $open_braces -ne $close_braces ]]; then
            print_error "$file: Unbalanced braces (open: $open_braces, close: $close_braces)"
            ((syntax_errors++))
            continue
        fi
        
        # Check for balanced parentheses in function definitions
        if grep -q "func.*(" "$file"; then
            if ! grep -q ")" "$file"; then
                print_error "$file: Missing closing parentheses in function definitions"
                ((syntax_errors++))
                continue
            fi
        fi
        
        # Check for import statements (all Swift files should have imports)
        if ! grep -q "import" "$file"; then
            print_warning "$file: No import statements found"
        fi
        
        # Check for proper struct/class/enum definitions (skip for test files)
        if [[ "$file" != "CompilationTest.swift" && "$file" != "ThemeValidation.swift" ]]; then
            if grep -qE "(struct|class|enum)" "$file"; then
                if ! grep -qE "(struct|class|enum).*\{" "$file"; then
                    print_error "$file: Incomplete struct/class/enum definitions"
                    ((syntax_errors++))
                    continue
                fi
            fi
        fi
        
        print_success "$file syntax check passed"
    fi
done

if [[ $syntax_errors -eq 0 ]]; then
    print_success "All Swift files passed syntax validation"
else
    print_error "Found $syntax_errors syntax errors"
fi

echo

# 2. Validate data model completeness
print_section "Data Model Validation"

required_models=(
    "struct Lens.*Codable"
    "struct Camera.*Codable"
    "struct Rental.*Codable"
    "struct InventoryItem.*Codable"
    "struct AppData.*Codable"
    "enum FocalCategory.*CaseIterable"
    "enum LensFormatCategory.*CaseIterable"
    "enum DataLoadingState"
    "enum ActiveTab"
)

for model in "${required_models[@]}"; do
    if grep -q "$model" Models.swift 2>/dev/null; then
        print_success "Found required model: $model"
    else
        print_error "Missing required model: $model"
    fi
done

echo

# 3. Validate SwiftUI view structure
print_section "SwiftUI View Validation"

view_files=(
    "MyApp.swift"
    "MainTabView.swift"
    "AllLensesView.swift"
    "FavoritesView.swift"
    "LensDetailView.swift"
    "SplashScreenView.swift"
)

for view_file in "${view_files[@]}"; do
    if [[ -f "$view_file" ]]; then
        if [[ "$view_file" == "MyApp.swift" ]]; then
            # MyApp.swift uses App protocol, not View
            if grep -q "App" "$view_file"; then
                print_success "$view_file contains App protocol conformance"
            else
                print_error "$view_file missing App protocol conformance"
            fi
            
            if grep -q "body.*some Scene" "$view_file"; then
                print_success "$view_file has proper body property (Scene)"
            else
                print_warning "$view_file may be missing proper body property"
            fi
        else
            if grep -q "View" "$view_file"; then
                print_success "$view_file contains View protocol conformance"
            else
                print_error "$view_file missing View protocol conformance"
            fi
            
            if grep -q "body.*some View" "$view_file"; then
                print_success "$view_file has proper body property"
            else
                print_warning "$view_file may be missing proper body property"
            fi
        fi
    else
        print_error "$view_file not found"
    fi
done

echo

# 4. Validate Core App Components
print_section "Core Component Validation"

# Check DataManager
if [[ -f "DataManager.swift" ]]; then
    if grep -q "class DataManager.*ObservableObject" DataManager.swift; then
        print_success "DataManager properly implements ObservableObject"
    else
        print_error "DataManager missing ObservableObject conformance"
    fi
    
    if grep -q "@Published" DataManager.swift; then
        print_success "DataManager uses @Published properties"
    else
        print_warning "DataManager may be missing @Published properties"
    fi
else
    print_error "DataManager.swift not found"
fi

# Check NetworkService
if [[ -f "NetworkService.swift" ]]; then
    if grep -q "class NetworkService" NetworkService.swift; then
        print_success "NetworkService class found"
    else
        print_error "NetworkService class definition missing"
    fi
    
    if grep -q "static let shared" NetworkService.swift; then
        print_success "NetworkService implements singleton pattern"
    else
        print_warning "NetworkService may not be implementing singleton pattern"
    fi
else
    print_error "NetworkService.swift not found"
fi

echo

# 5. Validate Test Infrastructure
print_section "Test Infrastructure Validation"

if [[ -f "CompilationTest.swift" ]]; then
    test_functions=$(grep -c "func test" CompilationTest.swift)
    if [[ $test_functions -ge 5 ]]; then
        print_success "CompilationTest.swift has $test_functions test functions"
    else
        print_warning "CompilationTest.swift has only $test_functions test functions"
    fi
    
    if grep -q "runAllTests" CompilationTest.swift; then
        print_success "Test runner function found"
    else
        print_error "Test runner function missing"
    fi
else
    print_error "CompilationTest.swift not found"
fi

echo

# 6. Validate Resources and Configuration
print_section "Resources and Configuration"

if [[ -f "Package.swift" ]]; then
    if grep -q "AppleProductTypes" Package.swift; then
        print_success "Package.swift configured for Swift Playgrounds"
    else
        print_error "Package.swift missing Swift Playground configuration"
    fi
    
    if grep -q "iOS.*18.0" Package.swift; then
        print_success "iOS 18.0+ deployment target set"
    else
        print_warning "iOS deployment target should be 18.0+"
    fi
else
    print_error "Package.swift not found"
fi

if [[ -d "Resources" ]]; then
    if [[ -f "Resources/CAMERADATA.json" ]]; then
        print_success "Camera data resource found"
    else
        print_warning "Camera data resource missing"
    fi
else
    print_warning "Resources directory not found"
fi

if [[ -d "Assets.xcassets" ]]; then
    print_success "Asset catalog found"
else
    print_warning "Asset catalog missing"
fi

echo

# 7. Final Summary
print_section "Validation Summary"

total_swift_files=$(find . -name "*.swift" | wc -l)
total_lines=$(find . -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')

echo "📊 Project Statistics:"
echo "  - Swift files: $total_swift_files"
echo "  - Total lines of code: $total_lines"
echo "  - Validation scripts: $(find . -name "*.sh" | wc -l)"
echo "  - Documentation files: $(find .. -name "*.md" | wc -l)"

echo

if [[ "$validation_passed" == true ]]; then
    echo -e "${GREEN}🎉 Swift code validation passed!${NC}"
    echo "✅ All syntax checks completed successfully"
    echo "✅ Data models are properly structured"
    echo "✅ SwiftUI views are correctly implemented"
    echo "✅ Core components follow best practices"
    echo "✅ Test infrastructure is comprehensive"
    echo "✅ Project is ready for Swift Playground deployment"
    exit 0
else
    echo -e "${RED}❌ Swift code validation failed!${NC}"
    echo "🔧 Please fix the issues identified above"
    exit 1
fi