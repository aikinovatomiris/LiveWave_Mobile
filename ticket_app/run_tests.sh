#!/bin/bash

# LiveWave Test Runner Script
# This script runs the complete test suite for the LiveWave mobile app

echo "================================================"
echo "LiveWave Mobile App - Test Suite Runner"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter not found. Please install Flutter SDK.${NC}"
    exit 1
fi

echo -e "${YELLOW}Flutter version:${NC}"
flutter --version
echo ""

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get
echo ""

# Run Unit Tests
echo -e "${YELLOW}================================================${NC}"
echo -e "${YELLOW}Running Unit Tests${NC}"
echo -e "${YELLOW}================================================${NC}"
echo ""

echo -e "${YELLOW}1. Testing Event Model...${NC}"
flutter test test/models/event_test.dart --coverage
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Event Model tests passed${NC}"
else
    echo -e "${RED}✗ Event Model tests failed${NC}"
fi
echo ""

echo -e "${YELLOW}2. Testing Seat Model...${NC}"
flutter test test/models/seat_test.dart --coverage
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Seat Model tests passed${NC}"
else
    echo -e "${RED}✗ Seat Model tests failed${NC}"
fi
echo ""

echo -e "${YELLOW}3. Testing API Service...${NC}"
flutter test test/services/api_service_test.dart --coverage
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ API Service tests passed${NC}"
else
    echo -e "${RED}✗ API Service tests failed${NC}"
fi
echo ""

echo -e "${YELLOW}4. Testing Event Card Widgets...${NC}"
flutter test test/widgets/event_card_test.dart --coverage
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Event Card Widget tests passed${NC}"
else
    echo -e "${RED}✗ Event Card Widget tests failed${NC}"
fi
echo ""

# Run All Unit Tests with Coverage
echo -e "${YELLOW}Running all unit tests with coverage...${NC}"
flutter test test/ --coverage
UNIT_TEST_RESULT=$?
echo ""

# Run Integration Tests (if device is available)
echo -e "${YELLOW}================================================${NC}"
echo -e "${YELLOW}Running Integration Tests${NC}"
echo -e "${YELLOW}================================================${NC}"
echo ""

# Check if a device is available
DEVICES=$(flutter devices | grep -c "device")
if [ $DEVICES -eq 0 ]; then
    echo -e "${YELLOW}No device/emulator found. Skipping integration tests.${NC}"
    echo "To run integration tests, please:"
    echo "  1. Start an Android emulator or iOS simulator"
    echo "  2. Or connect a physical device"
    echo "  3. Run: flutter test integration_test/"
    echo ""
else
    echo -e "${YELLOW}Device found. Running integration tests...${NC}"
    echo ""
    
    echo -e "${YELLOW}1. App Navigation Tests...${NC}"
    flutter test integration_test/app_test.dart
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ App Navigation tests passed${NC}"
    else
        echo -e "${RED}✗ App Navigation tests failed${NC}"
    fi
    echo ""

    echo -e "${YELLOW}2. Authentication Tests...${NC}"
    flutter test integration_test/auth_test.dart
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Authentication tests passed${NC}"
    else
        echo -e "${RED}✗ Authentication tests failed${NC}"
    fi
    echo ""

    echo -e "${YELLOW}3. Tickets & Booking Tests...${NC}"
    flutter test integration_test/tickets_test.dart
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Tickets & Booking tests passed${NC}"
    else
        echo -e "${RED}✗ Tickets & Booking tests failed${NC}"
    fi
    echo ""

    echo -e "${YELLOW}4. User Profile Tests...${NC}"
    flutter test integration_test/user_profile_test.dart
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ User Profile tests passed${NC}"
    else
        echo -e "${RED}✗ User Profile tests failed${NC}"
    fi
    echo ""

    # Run all integration tests
    echo -e "${YELLOW}Running all integration tests...${NC}"
    flutter test integration_test/
    INTEGRATION_TEST_RESULT=$?
fi

# Summary
echo ""
echo -e "${YELLOW}================================================${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}================================================${NC}"
echo ""

if [ $UNIT_TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓ Unit Tests: PASSED${NC}"
else
    echo -e "${RED}✗ Unit Tests: FAILED${NC}"
fi

if [ -z "$INTEGRATION_TEST_RESULT" ]; then
    echo -e "${YELLOW}⊘ Integration Tests: SKIPPED (no device)${NC}"
elif [ $INTEGRATION_TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓ Integration Tests: PASSED${NC}"
else
    echo -e "${RED}✗ Integration Tests: FAILED${NC}"
fi

echo ""
echo -e "${YELLOW}Coverage report generated in: coverage/lcov.info${NC}"
echo ""
echo -e "${YELLOW}For detailed testing guide, see: TESTING.md${NC}"
echo ""

if [ $UNIT_TEST_RESULT -ne 0 ] || ([ -n "$INTEGRATION_TEST_RESULT" ] && [ $INTEGRATION_TEST_RESULT -ne 0 ]); then
    exit 1
else
    exit 0
fi
