@echo off
REM LiveWave Test Runner Script for Windows
REM This script runs the complete test suite for the LiveWave mobile app

echo ================================================
echo LiveWave Mobile App - Test Suite Runner
echo ================================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo Flutter not found. Please install Flutter SDK.
    exit /b 1
)

echo Flutter version:
flutter --version
echo.

REM Get dependencies
echo Getting dependencies...
flutter pub get
echo.

REM Run Unit Tests
echo ================================================
echo Running Unit Tests
echo ================================================
echo.

echo 1. Testing Event Model...
flutter test test/models/event_test.dart --coverage
if errorlevel 1 (
    echo Event Model tests failed
) else (
    echo Event Model tests passed
)
echo.

echo 2. Testing Seat Model...
flutter test test/models/seat_test.dart --coverage
if errorlevel 1 (
    echo Seat Model tests failed
) else (
    echo Seat Model tests passed
)
echo.

echo 3. Testing API Service...
flutter test test/services/api_service_test.dart --coverage
if errorlevel 1 (
    echo API Service tests failed
) else (
    echo API Service tests passed
)
echo.

echo 4. Testing Event Card Widgets...
flutter test test/widgets/event_card_test.dart --coverage
if errorlevel 1 (
    echo Event Card Widget tests failed
) else (
    echo Event Card Widget tests passed
)
echo.

echo Running all unit tests with coverage...
flutter test test/ --coverage
set UNIT_TEST_RESULT=%errorlevel%
echo.

REM Run Integration Tests (if device is available)
echo ================================================
echo Running Integration Tests
echo ================================================
echo.

REM Check if a device is available
flutter devices >nul 2>&1
if errorlevel 1 (
    echo No device/emulator found. Skipping integration tests.
    echo To run integration tests, please:
    echo   1. Start an Android emulator or iOS simulator
    echo   2. Or connect a physical device
    echo   3. Run: flutter test integration_test/
    echo.
) else (
    echo Device found. Running integration tests...
    echo.

    echo 1. App Navigation Tests...
    flutter test integration_test/app_test.dart
    if errorlevel 1 (
        echo App Navigation tests failed
    ) else (
        echo App Navigation tests passed
    )
    echo.

    echo 2. Authentication Tests...
    flutter test integration_test/auth_test.dart
    if errorlevel 1 (
        echo Authentication tests failed
    ) else (
        echo Authentication tests passed
    )
    echo.

    echo 3. Tickets and Booking Tests...
    flutter test integration_test/tickets_test.dart
    if errorlevel 1 (
        echo Tickets and Booking tests failed
    ) else (
        echo Tickets and Booking tests passed
    )
    echo.

    echo 4. User Profile Tests...
    flutter test integration_test/user_profile_test.dart
    if errorlevel 1 (
        echo User Profile tests failed
    ) else (
        echo User Profile tests passed
    )
    echo.

    echo Running all integration tests...
    flutter test integration_test/
    set INTEGRATION_TEST_RESULT=%errorlevel%
)

REM Summary
echo.
echo ================================================
echo Test Summary
echo ================================================
echo.

if %UNIT_TEST_RESULT% equ 0 (
    echo Unit Tests: PASSED
) else (
    echo Unit Tests: FAILED
)

if defined INTEGRATION_TEST_RESULT (
    if %INTEGRATION_TEST_RESULT% equ 0 (
        echo Integration Tests: PASSED
    ) else (
        echo Integration Tests: FAILED
    )
) else (
    echo Integration Tests: SKIPPED (no device)
)

echo.
echo Coverage report generated in: coverage\lcov.info
echo.
echo For detailed testing guide, see: TESTING.md
echo.

exit /b %UNIT_TEST_RESULT%
