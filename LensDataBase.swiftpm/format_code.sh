#!/bin/bash

# Swift Code Formatter and Linter for LensDataBase
# This script fixes common formatting issues and enforces code style

echo "🔧 LensDataBase Code Formatter"
echo "=============================="
echo

cd "$(dirname "$0")"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_section() {
    echo -e "${BLUE}📋 $1${NC}"
    echo "$(printf '%.0s-' {1..30})"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Fix trailing whitespace
print_section "Fixing Trailing Whitespace"

swift_files=$(find . -name "*.swift" -type f)
fixed_files=0

for file in $swift_files; do
    if grep -q ' $' "$file"; then
        # Remove trailing whitespace
        sed -i 's/[[:space:]]*$//' "$file"
        print_success "Fixed trailing whitespace in $(basename "$file")"
        ((fixed_files++))
    fi
done

if [[ $fixed_files -eq 0 ]]; then
    print_success "No trailing whitespace found"
else
    print_warning "Fixed trailing whitespace in $fixed_files files"
fi

echo

# 2. Check and fix line endings
print_section "Normalizing Line Endings"

for file in $swift_files; do
    if file "$file" | grep -q "CRLF"; then
        # Convert CRLF to LF
        dos2unix "$file" 2>/dev/null || sed -i 's/\r$//' "$file"
        print_success "Fixed line endings in $(basename "$file")"
    fi
done

print_success "Line endings normalized"
echo

# 3. Check indentation consistency
print_section "Checking Indentation"

tab_files=$(grep -l $'\t' *.swift 2>/dev/null || echo "")
if [[ -n "$tab_files" ]]; then
    print_warning "Tab characters found - consider converting to spaces"
    echo "$tab_files"
else
    print_success "Consistent space indentation used"
fi

echo

# 4. Basic Swift formatting checks
print_section "Swift Style Checks"

# Check for proper spacing around operators
operator_issues=0
for file in $swift_files; do
    # Check for missing spaces around = operator
    if grep -n '[^=!<>]=\|=[^=]' "$file" | grep -v '==' | grep -v '>=' | grep -v '<=' | grep -v '!=' >/dev/null; then
        operator_issues=$((operator_issues + 1))
    fi
done

if [[ $operator_issues -eq 0 ]]; then
    print_success "Operator spacing looks good"
else
    print_warning "Found $operator_issues files with potential operator spacing issues"
fi

# Check for consistent brace style
brace_issues=$(grep -r '{$' *.swift | wc -l)
print_success "Found $brace_issues proper opening brace placements"

echo

# 5. Documentation checks
print_section "Documentation Style"

# Check for proper documentation comments
doc_functions=$(grep -r '^ *\/\*\*' *.swift | wc -l)
total_functions=$(grep -r 'func ' *.swift | wc -l)

if [[ $doc_functions -gt $((total_functions / 3)) ]]; then
    print_success "Good documentation coverage ($doc_functions/$total_functions functions)"
else
    print_warning "Consider adding more documentation comments"
fi

echo

# 6. Generate style report
print_section "Style Report"

echo "📊 Code Style Statistics:"
echo "  - Swift files processed: $(echo "$swift_files" | wc -l)"
echo "  - Files with trailing whitespace fixed: $fixed_files"
echo "  - Functions with documentation: $doc_functions"
echo "  - Total functions: $total_functions"

echo
print_success "Code formatting completed!"
echo
echo "💡 Tips for maintaining code quality:"
echo "  - Run this script before committing changes"
echo "  - Consider setting up automatic formatting in your editor"
echo "  - Use consistent naming conventions"
echo "  - Add documentation for public APIs"
echo