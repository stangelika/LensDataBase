#!/bin/bash

# Code Quality and Structure Validation Script for LensDataBase Swift Playground
# This script checks code formatting, structure, and potential issues

echo "🔍 LensDataBase Code Quality Check"
echo "=================================="
echo

cd "$(dirname "$0")"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
total_issues=0
total_warnings=0

# Function to print section headers
print_section() {
    echo -e "${BLUE}📋 $1${NC}"
    echo "$(printf '%.0s-' {1..40})"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((total_warnings++))
}

# Function to print error
print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((total_issues++))
}

# 1. File Structure Validation
print_section "File Structure Validation"

required_files=(
    "MyApp.swift"
    "Models.swift" 
    "NetworkService.swift"
    "DataManager.swift"
    "AllLensesView.swift"
    "MainTabView.swift"
    "AppTheme.swift"
    "Package.swift"
    "CompilationTest.swift"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "$file exists"
    else
        print_error "$file is missing"
    fi
done

echo

# 2. Code Structure Analysis
print_section "Code Structure Analysis"

# Check file sizes (warn if too large)
echo "File size analysis:"
while IFS= read -r line; do
    lines=$(echo "$line" | awk '{print $1}')
    file=$(echo "$line" | awk '{print $2}')
    
    if [[ "$file" == "total" ]]; then
        continue
    fi
    
    if [[ $lines -gt 400 ]]; then
        print_warning "$file has $lines lines (consider splitting)"
    elif [[ $lines -gt 300 ]]; then
        print_warning "$file has $lines lines (getting large)"
    else
        print_success "$file has $lines lines"
    fi
done < <(wc -l *.swift | head -n -1)

echo

# 3. Code Quality Checks
print_section "Code Quality Checks"

# Check for Russian comments/text (should be minimal or none)
echo "Checking for Russian text:"
russian_count=$(grep -r '[а-яё]' *.swift 2>/dev/null | wc -l || echo "0")
if [[ $russian_count -eq 0 ]]; then
    print_success "No Russian text found in code"
else
    print_warning "Found $russian_count lines with Russian text"
fi

# Check for TODO/FIXME comments
echo "Checking for TODO/FIXME comments:"
todo_count=$(grep -ri "TODO\|FIXME" *.swift 2>/dev/null | wc -l || echo "0")
if [[ $todo_count -eq 0 ]]; then
    print_success "No TODO/FIXME comments found"
else
    print_warning "Found $todo_count TODO/FIXME comments"
fi

# Check for hardcoded strings that should be localized
echo "Checking for potential hardcoded strings:"
hardcoded_count=$(grep -r '"[A-Za-z]' *.swift | grep -v "id:" | grep -v "name:" | grep -v "test" | wc -l || echo "0")
if [[ $hardcoded_count -lt 20 ]]; then
    print_success "Reasonable number of hardcoded strings ($hardcoded_count)"
else
    print_warning "Many hardcoded strings found ($hardcoded_count) - consider localization"
fi

echo

# 4. Swift Code Formatting
print_section "Swift Code Formatting"

# Check for consistent indentation
echo "Checking indentation consistency:"
tab_files=$(grep -l $'\t' *.swift 2>/dev/null || echo "")
if [[ -z "$tab_files" ]]; then
    print_success "No tab characters found (using spaces)"
else
    print_warning "Tab characters found in: $tab_files"
fi

# Check for trailing whitespace
echo "Checking for trailing whitespace:"
trailing_count=$(grep -r ' $' *.swift 2>/dev/null | wc -l || echo "0")
if [[ $trailing_count -eq 0 ]]; then
    print_success "No trailing whitespace found"
else
    print_warning "Found $trailing_count lines with trailing whitespace"
fi

# Check line endings (should be Unix style)
echo "Checking line endings:"
dos_files=$(file *.swift | grep -i "crlf" || echo "")
if [[ -z "$dos_files" ]]; then
    print_success "All files use Unix line endings"
else
    print_warning "Files with DOS line endings found"
fi

echo

# 5. Swift Playground Specific Checks
print_section "Swift Playground Validation"

# Check Package.swift structure
if [[ -f "Package.swift" ]]; then
    if grep -q "AppleProductTypes" Package.swift; then
        print_success "Package.swift includes AppleProductTypes (Swift Playground compatible)"
    else
        print_error "Package.swift missing AppleProductTypes import"
    fi
    
    if grep -q "iOS" Package.swift; then
        print_success "iOS platform specified in Package.swift"
    else
        print_warning "iOS platform not clearly specified"
    fi
else
    print_error "Package.swift not found"
fi

# Check for proper @main app structure
if grep -q "@main" MyApp.swift 2>/dev/null; then
    print_success "App has proper @main entry point"
else
    print_error "Missing @main entry point in MyApp.swift"
fi

echo

# 6. Testing Infrastructure
print_section "Testing Infrastructure"

if [[ -f "CompilationTest.swift" ]]; then
    test_functions=$(grep "func test" CompilationTest.swift | wc -l)
    if [[ $test_functions -gt 3 ]]; then
        print_success "CompilationTest.swift has $test_functions test functions"
    else
        print_warning "CompilationTest.swift has only $test_functions test functions"
    fi
else
    print_error "CompilationTest.swift not found"
fi

if [[ -f "verify_project.sh" ]]; then
    print_success "Project verification script exists"
else
    print_warning "Project verification script missing"
fi

echo

# 7. Documentation Checks
print_section "Documentation Checks"

# Check for README
if [[ -f "../README.md" ]]; then
    readme_lines=$(wc -l < "../README.md")
    if [[ $readme_lines -gt 100 ]]; then
        print_success "Comprehensive README.md exists ($readme_lines lines)"
    else
        print_warning "README.md exists but may be incomplete ($readme_lines lines)"
    fi
else
    print_error "README.md not found"
fi

# Check for API documentation
if [[ -f "../API_KEYS_DOCUMENTATION_Version3.md" ]]; then
    print_success "API documentation exists"
else
    print_warning "API documentation not found"
fi

echo

# 8. Summary
print_section "Summary"

total_files=$(find . -name "*.swift" | wc -l)
total_lines=$(find . -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')

echo "📊 Project Statistics:"
echo "  - Swift files: $total_files"
echo "  - Total lines: $total_lines"
echo "  - Warnings: $total_warnings"
echo "  - Issues: $total_issues"
echo

if [[ $total_issues -eq 0 ]]; then
    if [[ $total_warnings -eq 0 ]]; then
        echo -e "${GREEN}🎉 Excellent! No issues or warnings found.${NC}"
        exit 0
    else
        echo -e "${YELLOW}✅ Good! No critical issues, but $total_warnings warnings to consider.${NC}"
        exit 0
    fi
else
    echo -e "${RED}⚠️  Found $total_issues critical issues that should be addressed.${NC}"
    exit 1
fi