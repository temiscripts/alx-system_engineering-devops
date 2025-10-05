#!/bin/bash
# test_all.sh - Comprehensive test script for all shell variable scripts

echo "🧪 Starting comprehensive tests for Shell Variables & Expansions project..."
echo "=================================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
tests_passed=0
tests_total=0

# Function to run test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected="$3"
    
    ((tests_total++))
    echo -e "\n${YELLOW}Test $tests_total: $test_name${NC}"
    
    result=$(eval "$command" 2>/dev/null)
    
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - Output: $result"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - Expected: $expected, Got: $result"
    fi
}

# Test 1: Hello user
echo -e "\n${YELLOW}Testing 1-hello_you script...${NC}"
if [[ -x "./1-hello_you" ]]; then
    result=$(./1-hello_you)
    expected="hello $USER"
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 1-hello_you works correctly"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 1-hello_you output incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 1-hello_you not executable"
    ((tests_total++))
fi

# Test 2: Path counting
echo -e "\n${YELLOW}Testing 3-paths script...${NC}"
if [[ -x "./3-paths" ]]; then
    result=$(./3-paths)
    expected=$(echo "$PATH" | tr ':' '\n' | wc -l)
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 3-paths counts correctly"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 3-paths count incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 3-paths not executable"
    ((tests_total++))
fi

# Test 3: True knowledge arithmetic
echo -e "\n${YELLOW}Testing 8-true_knowledge script...${NC}"
if [[ -x "./8-true_knowledge" ]]; then
    export TRUEKNOWLEDGE=1209
    result=$(./8-true_knowledge)
    expected="1337"
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 8-true_knowledge calculates correctly"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 8-true_knowledge calculation incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 8-true_knowledge not executable"
    ((tests_total++))
fi

# Test 4: Division
echo -e "\n${YELLOW}Testing 9-divide_and_rule script...${NC}"
if [[ -x "./9-divide_and_rule" ]]; then
    export POWER=42784
    export DIVIDE=32
    result=$(./9-divide_and_rule)
    expected="1337"
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 9-divide_and_rule calculates correctly"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 9-divide_and_rule calculation incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 9-divide_and_rule not executable"
    ((tests_total++))
fi

# Test 5: Exponentiation
echo -e "\n${YELLOW}Testing 10-love_exponent_breath script...${NC}"
if [[ -x "./10-love_exponent_breath" ]]; then
    export BREATH=4
    export LOVE=3
    result=$(./10-love_exponent_breath)
    expected="64"
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 10-love_exponent_breath calculates correctly"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 10-love_exponent_breath calculation incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 10-love_exponent_breath not executable"
    ((tests_total++))
fi

# Test 6: Binary to decimal
echo -e "\n${YELLOW}Testing 11-binary_to_decimal script...${NC}"
if [[ -x "./11-binary_to_decimal" ]]; then
    export BINARY=10100111001
    result=$(./11-binary_to_decimal)
    expected="1337"
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 11-binary_to_decimal converts correctly"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 11-binary_to_decimal conversion incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 11-binary_to_decimal not executable"
    ((tests_total++))
fi

# Test 7: Float formatting
echo -e "\n${YELLOW}Testing 13-print_float script...${NC}"
if [[ -x "./13-print_float" ]]; then
    export NUM=3.14159265359
    result=$(./13-print_float)
    expected="3.14"
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 13-print_float formats correctly"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 13-print_float formatting incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 13-print_float not executable"
    ((tests_total++))
fi

# Test 8: Combinations count
echo -e "\n${YELLOW}Testing 12-combinations script...${NC}"
if [[ -x "./12-combinations" ]]; then
    result=$(./12-combinations | wc -l)
    expected="675"
    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - 12-combinations generates correct count"
        ((tests_passed++))
    else
        echo -e "${RED}✗ FAILED${NC} - 12-combinations count incorrect"
    fi
    ((tests_total++))
else
    echo -e "${RED}✗ FAILED${NC} - 12-combinations not executable"
    ((tests_total++))
fi

# Check file line counts
echo -e "\n${YELLOW}Checking file line requirements...${NC}"
for file in 0-alias 1-hello_you 2-path 3-paths 4-global_variables 5-local_variables 6-create_local_variable 7-create_global_variable 8-true_knowledge 9-divide_and_rule 10-love_exponent_breath 11-binary_to_decimal 12-combinations 13-print_float; do
    if [[ -f "$file" ]]; then
        lines=$(wc -l < "$file")
        if [[ "$lines" == "2" ]]; then
            echo -e "${GREEN}✓${NC} $file has correct line count (2)"
            ((tests_passed++))
        else
            echo -e "${RED}✗${NC} $file has incorrect line count ($lines, should be 2)"
        fi
        ((tests_total++))
    fi
done

# Final summary
echo -e "\n=================================================================="
echo -e "${YELLOW}Test Summary:${NC}"
echo -e "Tests passed: ${GREEN}$tests_passed${NC}/$tests_total"

if [[ $tests_passed == $tests_total ]]; then
    echo -e "${GREEN}🎉 All tests passed! Your project is ready for submission.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please check your scripts.${NC}"
    exit 1
fi
