@echo off
REM Flutter Driver Test Runner for Windows
REM Usage: run_driver_tests.bat [test_file|all]

setlocal enabledelayedexpansion

REM Color codes (using ANSI escape sequences)
set "BLUE=[34m"
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"
set "RESET=[0m"

REM Configuration
set "PROJECT_DIR=%~dp0"
set "TEST_DIR=%PROJECT_DIR%test_driver"
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set "TIMESTAMP=%mydate%_%mytime%"
set "LOG_FILE=%PROJECT_DIR%driver_test_%TIMESTAMP%.log"

cls
echo %BLUE%╔════════════════════════════════════════╗%RESET%
echo %BLUE%║  Flutter Driver Test Runner            ║%RESET%
echo %BLUE%╚════════════════════════════════════════╝%RESET%
echo.

REM Function to check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo %RED%✗ Flutter SDK not found. Please install Flutter.%RESET%
    exit /b 1
)

REM Function to check if device is connected
:check_device
echo %BLUE%[%time%] Checking for connected devices...%RESET%
flutter devices > nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo %RED%✗ No devices found. Please connect a device or start an emulator.%RESET%
    echo.
    echo To start Android emulator:
    echo   emulator -avd emulator_name
    echo.
    echo To start iOS simulator:
    echo   open -a Simulator
    echo.
    exit /b 1
)

echo %GREEN%✓ Device(s) found%RESET%
flutter devices
echo.

REM Function to run tests
:run_test
set "TEST_FILE=%~1"
set "TEST_NAME=%~n1"
set "TEST_NAME=%TEST_NAME:_test.dart=%"

echo %BLUE%[%time%] Running %TEST_NAME%...%RESET%
echo.

flutter driver --target=test_driver/app.dart --driver="%TEST_FILE%" -v >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% EQU 0 (
    echo %GREEN%✓ %TEST_NAME% passed%RESET%
    echo.
    exit /b 0
) else (
    echo %RED%✗ %TEST_NAME% failed%RESET%
    echo.
    exit /b 1
)

REM Main logic
if "%~1"=="" (
    call :show_help
    exit /b 0
)

set "COMMAND=%~1"

if /i "%COMMAND%"=="help" (
    call :show_help
    exit /b 0
)

if /i "%COMMAND%"=="list" (
    call :list_tests
    exit /b 0
)

if /i "%COMMAND%"=="clean" (
    echo %BLUE%[%time%] Cleaning previous builds...%RESET%
    flutter clean > nul 2>&1
    flutter pub get > nul 2>&1
    echo %GREEN%✓ Clean complete%RESET%
    exit /b 0
)

if /i "%COMMAND%"=="all" (
    call :check_device
    echo %BLUE%[%time%] Cleaning previous builds...%RESET%
    flutter clean > nul 2>&1
    flutter pub get > nul 2>&1
    echo %GREEN%✓ Clean complete%RESET%
    echo.
    
    echo %BLUE%[%time%] Running all Flutter Driver tests...%RESET%
    echo.
    
    set TOTAL=0
    set PASSED=0
    set FAILED=0
    
    for %%f in ("%TEST_DIR%\*_test.dart") do (
        set /a TOTAL=!TOTAL!+1
        
        call :run_test "%%f"
        if !ERRORLEVEL! EQU 0 (
            set /a PASSED=!PASSED!+1
        ) else (
            set /a FAILED=!FAILED!+1
        )
    )
    
    echo.
    echo %BLUE%═════════════════════════════════════════%RESET%
    echo %BLUE%Test Summary%RESET%
    echo %BLUE%═════════════════════════════════════════%RESET%
    echo Total:  !TOTAL!
    echo Passed: %GREEN%!PASSED!%RESET%
    if !FAILED! GTR 0 (
        echo Failed: %RED%!FAILED!%RESET%
    ) else (
        echo Failed: !FAILED!
    )
    echo %BLUE%═════════════════════════════════════════%RESET%
    echo.
    
    if !FAILED! EQU 0 (
        echo %GREEN%✓ All tests passed!%RESET%
        exit /b 0
    ) else (
        echo %RED%✗ Some tests failed%RESET%
        exit /b 1
    )
) else (
    REM Try to run as specific test
    set "TEST_FILE=%TEST_DIR%\%COMMAND%_test.dart"
    
    if exist "!TEST_FILE!" (
        call :check_device
        echo %BLUE%[%time%] Cleaning previous builds...%RESET%
        flutter clean > nul 2>&1
        flutter pub get > nul 2>&1
        echo %GREEN%✓ Clean complete%RESET%
        echo.
        
        call :run_test "!TEST_FILE!"
        exit /b !ERRORLEVEL!
    ) else (
        echo %RED%✗ Unknown command or test file: %COMMAND%%RESET%
        echo.
        call :show_help
        exit /b 1
    )
)

:show_help
echo Usage: %0 [OPTION]
echo.
echo Options:
echo   all                 Run all Flutter Driver tests
echo   app_test            Run app navigation tests
echo   auth_test           Run authentication flow tests
echo   list                List available test files
echo   clean               Clean build artifacts
echo   help                Show this help message
echo.
echo Examples:
echo   %0 all              # Run all tests
echo   %0 app_test         # Run specific test file
echo   %0 list             # List available tests
echo.
exit /b 0

:list_tests
echo %BLUE%[%time%] Available test files:%RESET%
echo.
for %%f in ("%TEST_DIR%\*_test.dart") do (
    set "FILENAME=%%~nf"
    set "FILENAME=!FILENAME:_test.dart=!"
    echo   • !FILENAME!
)
echo.
exit /b 0
