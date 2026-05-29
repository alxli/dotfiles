#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Toggle Dock Position"
APP_PATH="/Applications/$APP_NAME.app"

if [ "$EUID" -ne 0 ]; then
    echo "Installing to /Applications requires admin privileges."
    exec sudo "$0" "$@"
fi

echo "Building $APP_NAME..."
osacompile -o "$APP_PATH" "$SCRIPT_DIR/toggle_dock_position.applescript"

if [ -f "$SCRIPT_DIR/icon.icns" ]; then
    rm -f "$APP_PATH/Contents/Resources/Assets.car"
    cp "$SCRIPT_DIR/icon.icns" "$APP_PATH/Contents/Resources/applet.icns"
    touch "$APP_PATH"
    echo "Custom icon applied."
fi

echo "Installed to $APP_PATH"
echo "You can now drag it from Applications to your Dock."
