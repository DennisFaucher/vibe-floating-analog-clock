cmake_minimum_required(VERSION 3.15)
project(VibeClock)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable Objective-C++ compilation
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD_REQUIRED ON)

# Set minimum macOS version
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.14")

# Source files
set(SOURCES
    main.mm
    ClockWindow.mm
    ClockView.mm
    ClockSettings.mm
    SettingsWindow.mm
)

# Create executable
add_executable(VibeClock ${SOURCES})

# Link frameworks
target_link_libraries(VibeClock
    "-framework AppKit"
    "-framework Foundation"
    "-framework CoreGraphics"
)

# Set bundle properties
set_target_properties(VibeClock PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
    MACOSX_BUNDLE_BUNDLE_NAME "VibeClock"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.vibeclock.app"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
)

# Copy Info.plist to build directory
set_source_files_properties(Info.plist PROPERTIES MACOSX_PACKAGE_LOCATION ".")

# Copy Info.plist to bundle after build (ensure it's up to date)
add_custom_command(TARGET VibeClock POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist" "${CMAKE_CURRENT_BINARY_DIR}/VibeClock.app/Contents/Info.plist"
    COMMENT "Copying Info.plist to app bundle"
)

# Copy app icon to bundle Resources folder
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/AppIcon.icns")
    add_custom_command(TARGET VibeClock POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/VibeClock.app/Contents/Resources"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/AppIcon.icns" "${CMAKE_CURRENT_BINARY_DIR}/VibeClock.app/Contents/Resources/AppIcon.icns"
        COMMENT "Copying app icon to bundle"
    )
endif()

# Code sign the app bundle (ad-hoc signing for local development)
# First remove extended attributes (resource forks) that interfere with signing
add_custom_command(TARGET VibeClock POST_BUILD
    COMMAND xattr -cr VibeClock.app || true
    COMMAND codesign --force --deep --sign - VibeClock.app
    COMMENT "Code signing VibeClock.app"
)
