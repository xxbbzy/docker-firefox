#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename "$0"): $*"
}

FCITX5_CONFIG_DIR="/config/.config/fcitx5"

# Create fcitx5 config directory.
mkdir -p "$FCITX5_CONFIG_DIR/conf"

# Create default profile if not exists.
if [ ! -f "$FCITX5_CONFIG_DIR/profile" ]; then
    log "Creating default fcitx5 profile..."
    cat > "$FCITX5_CONFIG_DIR/profile" << 'EOF'
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=pinyin

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=pinyin
# Layout
Layout=

[GroupOrder]
0=Default
EOF
fi

# Create default config if not exists.
if [ ! -f "$FCITX5_CONFIG_DIR/config" ]; then
    log "Creating default fcitx5 config..."
    cat > "$FCITX5_CONFIG_DIR/config" << 'EOF'
[Hotkey]
# Trigger Input Method
TriggerKeys="Control+space"
# Enumerate Input Method Forward
EnumerateForwardKeys=
# Enumerate Input Method Backward
EnumerateBackwardKeys=
# Enumerate Input Method Skip First
EnumerateSkipFirst=False

[Hotkey/TriggerKeys]
0=Control+space

[Behavior]
# Active By Default
ActiveByDefault=False
# Share Input State
ShareInputState=No
# Show preedit in application
PreeditEnabledByDefault=True
# Show Input Method Information when switch input method
ShowInputMethodInformation=True
# Show Input Method Information when changing focus
ShowInputMethodInformationWhenFocusIn=False
# Show compact input method information
CompactInputMethodInformation=True
# Show first input method information
ShowFirstInputMethodInformation=True
# Default page size
DefaultPageSize=5
# Override Xkb Option
OverrideXkbOption=False
# Custom Xkb Option
CustomXkbOption=
# Force Enabled Addons
EnabledAddons=
# Force Disabled Addons
DisabledAddons=
# Preload input method to be used by default
PreloadInputMethod=True
EOF
fi

# Set correct ownership.
take-ownership "$FCITX5_CONFIG_DIR"

log "fcitx5 configuration initialized."
