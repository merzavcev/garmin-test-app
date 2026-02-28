# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Garmin Connect IQ watch application (watch-app) written in Monkey C, targeting vívoactive 6 devices. The app displays "Hello Garmin" on the watch screen.

## Required Environment Setup

Before building, ensure these environment variables are set:

```bash
export CIQ_SDK_HOME="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.4.1-2026-02-03-e9f77eeaa"
export CIQ_DEVELOPER_KEY="$HOME/.garmin/developer_key.der"
export CIQ_TARGET="vivoactive6"  # Optional: defaults to vivoactive6
```

- `CIQ_SDK_HOME`: Required. Path to Connect IQ SDK 8.4.1+
- `CIQ_DEVELOPER_KEY`: Required. Path to developer signing key (.der file). SDK 8.4.1+ does not support unsigned builds
- `JAVA_HOME`: May be required if multiple JVMs are installed (requires JDK 17+)

## Build Commands

Build signed .prg file (default target vivoactive6, output to build/HelloGarmin.prg):
```bash
./scripts/build.sh
```

Build with explicit target:
```bash
./scripts/build.sh --target vivoactive6
```

Build with custom output:
```bash
./scripts/build.sh --target vivoactive6 --output build/MyApp.prg
```

Package the built .prg into dist/ directory:
```bash
./scripts/package.sh
```

Package with rebuild:
```bash
./scripts/package.sh --rebuild
```

## Running in Simulator

1. Open Connect IQ Simulator: `$CIQ_SDK_HOME/bin/ConnectIQ.app`
2. In Device Manager, add vívoactive 6 device (Window → Device Manager → Add Device)
3. Enable Settings → Allow Remote Connections
4. Run from project root:
```bash
"$CIQ_SDK_HOME/bin/monkeydo" build/HelloGarmin.prg vivoactive6
```

## Connect IQ Application Architecture

Connect IQ apps follow the Model-View-Controller pattern with these key components:

### Application Entry Point (source/App.mc)
- Main class extends `Application.AppBase`
- `initialize()`: App initialization
- `onStart(state)`: Called when app starts, receives state dictionary
- `onStop(state)`: Called when app stops, can save state
- `getInitialView()`: Returns the initial View (and optional InputDelegate)

### View Layer (source/View.mc)
- Extends `WatchUi.View`
- `onLayout(dc)`: Layout setup, called once
- `onShow()`: Called when view becomes visible
- `onUpdate(dc)`: Render method, draws UI using DrawingContext (dc)
- `onHide()`: Called when view is hidden

### Drawing Context (dc)
The `dc` parameter in view methods provides drawing capabilities:
- `dc.clear()`: Clear screen
- `dc.setColor(fg, bg)`: Set foreground/background colors
- `dc.drawText(x, y, font, text, justification)`: Draw text
- `dc.getWidth()` / `dc.getHeight()`: Get screen dimensions

### Project Structure
- `manifest.xml`: App metadata, target devices, permissions, supported languages
- `monkey.jungle`: Project configuration (minimal, points to manifest.xml)
- `source/*.mc`: Monkey C source files
- `resources/strings/strings.xml`: Localized string resources
- `resources/drawables/`: Images including launcher icon
- `build/`: Compiled .prg output
- `bin/`: Alternative build output directory
- `dist/`: Packaged distribution artifacts

### Adding Features
When adding new views or functionality:
1. Create new .mc files in `source/`
2. Import required Toybox modules (Graphics, WatchUi, Lang, etc.)
3. Update getInitialView() or push new views via WatchUi.pushView()
4. Add InputDelegates for user input handling (buttons, touch, etc.)
5. Update manifest.xml if adding permissions or changing supported devices
