# VibeFloatingClock

Today, I could no longer install my favorite SimpleFloatingClock.app, so I asked Cursor to help me re-create. Thanks, Cursor!

A beautiful, customizable analog clock application for macOS. VibeFloatingClock features a classic Swiss railway clock design with a circular, borderless window that can be positioned anywhere on your screen.

![VibeClock](https://img.shields.io/badge/macOS-10.14+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

- **Swiss Railway Clock Design**: Classic, minimalist clock face inspired by Swiss railway station clocks
- **Customizable Appearance**:
  - Clock face color
  - Hour and minute hand colors
  - TZ Hand (timezone hand) with customizable color and timezone selection
  - Day of month display with customizable font, size, and position
- **Window Customization**:
  - Adjustable opacity (0-100%)
  - Resizable diameter (100-2000 pixels)
  - Always on Top option
  - Click Through mode (allows clicks to pass through the clock window)
- **Frameless & Draggable**: Circular window with no decorations - just the clock
- **Resizable**: Drag corners/edges to resize while maintaining circular shape
- **Multiple Timezones**: TZ Hand displays time for any selected world timezone

## Requirements

- macOS 10.14 (Mojave) or later
- CMake 3.15 or later
- Xcode Command Line Tools

## Building

1. Clone the repository:
```bash
git clone <repository-url>
cd VibeClock
```

2. Create a build directory:
```bash
mkdir build
cd build
```

3. Configure and build:
```bash
cmake ..
make
```

4. The app will be built at `build/VibeClock.app`

5. Run the app:
```bash
open VibeClock.app
```

## Usage

### Basic Operations

- **Move the clock**: Click and drag anywhere on the clock face
- **Resize the clock**: Click and drag the edges or corners
- **Open Settings**: Use the menu bar → Settings → Settings... (or press `Cmd+,`)
- **Toggle Always on Top**: View → Always on Top (or press `Cmd+T`)
- **Toggle Click Through**: View → Click Through (or press `Cmd+Shift+C`)

### Settings

Access settings via the menu bar or `Cmd+,`:

- **Clock Face Color**: Choose the background color of the clock
- **Hour Hand Color**: Customize the hour hand color
- **Minute Hand Color**: Customize the minute hand color
- **TZ Hand Color**: Set the color for the timezone hand
- **TZ Hand Timezone**: Select from 30+ world timezones
- **Day of Month Font**: Choose font name and size
- **Day of Month Position**: Set X and Y coordinates (0,0 uses default position above 6:00)
- **Opacity**: Adjust window transparency (0-100%)
- **Diameter**: Set clock size in pixels (100-2000)

### Menu Bar

- **View Menu**:
  - Always on Top (`Cmd+T`)
  - Click Through (`Cmd+Shift+C`)
- **Settings Menu**:
  - Settings... (`Cmd+,`)

## Project Structure

```
VibeClock/
├── CMakeLists.txt          # Build configuration
├── Info.plist              # macOS app bundle metadata
├── AppIcon.icns            # Application icon
├── main.mm                 # Application entry point and menu setup
├── ClockWindow.h/.mm       # Custom frameless window implementation
├── ClockView.h/.mm         # Clock drawing and rendering
├── ClockSettings.h/.mm      # Settings persistence (NSUserDefaults)
├── SettingsWindow.h/.mm     # Settings UI
└── README.md               # This file
```

## Technical Details

- **Language**: C++ with Objective-C++ (for macOS APIs)
- **Frameworks**: AppKit, Foundation, CoreGraphics
- **Build System**: CMake
- **Settings Storage**: NSUserDefaults
- **Drawing**: Core Graphics (CGContextRef)
- **Window Management**: Custom NSWindow subclass with circular masking

## Customization

### Creating a Custom Icon

1. Create an `AppIcon.iconset` directory
2. Add PNG images at the following sizes:
   - `icon_16x16.png` (16x16)
   - `icon_16x16@2x.png` (32x32)
   - `icon_32x32.png` (32x32)
   - `icon_32x32@2x.png` (64x64)
   - `icon_128x128.png` (128x128)
   - `icon_128x128@2x.png` (256x256)
   - `icon_256x256.png` (256x256)
   - `icon_256x256@2x.png` (512x512)
   - `icon_512x512.png` (512x512)
   - `icon_512x512@2x.png` (1024x1024)
3. Convert to .icns:
```bash
iconutil -c icns AppIcon.iconset -o AppIcon.icns
```

## Troubleshooting

### App won't open ("damaged or incomplete")

The app is ad-hoc signed during build. If macOS blocks it:
1. Right-click the app
2. Select "Open"
3. Click "Open" in the security dialog

### Icon doesn't appear

Ensure `AppIcon.icns` exists in the project root and is copied to the bundle during build.

### Settings not persisting

Settings are stored in `~/Library/Preferences/com.vibeclock.app.plist`. If issues occur, delete this file to reset to defaults.

## License

GNU General Public License v3.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Cursor, Cursor, Cursor!
- Clock design inspired by Swiss railway station clocks
- Built with native macOS frameworks for optimal performance

