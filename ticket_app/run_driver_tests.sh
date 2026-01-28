#!/bin/bash

# Flutter Driver Test Runner for macOS/Linux
# Usage: ./run_driver_tests.sh [test_file|all]

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$PROJECT_DIR/test_driver"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$PROJECT_DIR/driver_test_${TIMESTAMP}.log"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Flutter Driver Test Runner            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to check if device is connected
check_device() {
    print_status "Checking for connected devices..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter SDK not found. Please install Flutter."
        exit 1
    fi

    DEVICES=$(flutter devices 2>/dev/null | grep -c "connected" || echo "0")
    
    if [ "$DEVICES" -eq 0 ]; then
        print_error "No devices found. Please connect a device or start an emulator."
        echo ""
        echo "To start Android emulator:"
        echo "  emulator -avd emulator_name"
        echo ""
        echo "To start iOS simulator:"
        echo "  open -a Simulator"
        echo ""
        exit 1
    fi
    
    print_success "Found $DEVICES device(s)"
    flutter devices
}

# Function to clean previous builds
clean_build() {
    print_status "Cleaning previous builds..."
    flutter clean > /dev/null 2>&1 || true
    flutter pub get > /dev/null 2>&1 || true
    print_success "Clean complete"
}

# Function to run a single test file
run_test() {
    local TEST_FILE=$1
    local TEST_NAME=$(basename "$TEST_FILE" .dart)
    
    print_status "Running ${TEST_NAME}..."
    echo ""
    
    if flutter driver \
        --target=test_driver/app.dart \
        --driver="$TEST_FILE" \
        -v 2>&1 | tee -a "$LOG_FILE"; then
        
        print_success "${TEST_NAME} passed"
        echo ""
        return 0
    else
        print_error "${TEST_NAME} failed"
        echo ""
        return 1
    fi
}

# Function to run all tests
run_all_tests() {
    print_status "Running all Flutter Driver tests..."
    echo ""
    
    local TOTAL=0
    local PASSED=0
    local FAILED=0
    
    for test_file in "$TEST_DIR"/*_test.dart; do
        if [ -f "$test_file" ]; then
            TOTAL=$((TOTAL + 1))
            
            if run_test "$test_file"; then
                PASSED=$((PASSED + 1))
            else
                FAILED=$((FAILED + 1))
            fi
        fi
    done
    
    echo ""
    echo -e "${BLUE}═════════════════════════════════════════${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}═════════════════════════════════════════${NC}"
    echo -e "Total:  $TOTAL"
    echo -e "Passed: ${GREEN}$PASSED${NC}"
    if [ "$FAILED" -gt 0 ]; then
        echo -e "Failed: ${RED}$FAILED${NC}"
    else
        echo -e "Failed: $FAILED"
    fi
    echo -e "${BLUE}═════════════════════════════════════════${NC}"
    
    return $FAILED
}

# Function to display available tests
list_tests() {
    print_status "Available test files:"
    echo ""
    for test_file in "$TEST_DIR"/*_test.dart; do
        if [ -f "$test_file" ]; then
            TEST_NAME=$(basename "$test_file" .dart)
            echo "  • $TEST_NAME"
        fi
    done
    echo ""
}

# Function to display help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  all                 Run all Flutter Driver tests"
    echo "  app_test            Run app navigation tests"
    echo "  auth_test           Run authentication flow tests"
    echo "  list                List available test files"
    echo "  clean               Clean build artifacts"
    echo "  help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 all              # Run all tests"
    echo "  $0 app_test         # Run specific test file"
    echo "  $0 list             # List available tests"
    echo ""
}

# Main logic
main() {
    # Create log file
    touch "$LOG_FILE"
    print_status "Logging to: $LOG_FILE"
    echo ""
    
    # Check for arguments
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    COMMAND=$1
    
    case $COMMAND in
        help)
            show_help
            exit 0
            ;;
        list)
            list_tests
            exit 0
            ;;
        clean)
            clean_build
            exit 0
            ;;
        all)
            check_device
            clean_build
            run_all_tests
            EXIT_CODE=$?
            ;;
        *)
            # Try to run as specific test
            TEST_FILE="$TEST_DIR/${COMMAND}_test.dart"
            
            if [ -f "$TEST_FILE" ]; then
                check_device
                clean_build
                run_test "$TEST_FILE"
                EXIT_CODE=$?
            else
                print_error "Unknown command or test file: $COMMAND"
                echo ""
                show_help
                exit 1
            fi
            ;;
    esac
    
    # Print final status
    echo ""
    print_status "Test run completed"
    print_status "Logs saved to: $LOG_FILE"
    echo ""
    
    if [ ${EXIT_CODE:-0} -eq 0 ]; then
        print_success "All tests passed!"
        exit 0
    else
        print_error "Some tests failed"
        exit 1
    fi
}

# Run main function
main "$@"
