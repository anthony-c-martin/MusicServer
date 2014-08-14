#!/bin/sh

rm -rf "/Applications/$PROJECT_NAME.app"
cp -rf "$INSTALL_DIR/$PROJECT_NAME.app" "/Applications/"
rm -f "$HOME/Desktop/$PROJECT_NAME.dmg"
hdiutil create -srcfolder "$INSTALL_DIR" -volname "$PROJECT_NAME" "$HOME/Desktop/$PROJECT_NAME.dmg"