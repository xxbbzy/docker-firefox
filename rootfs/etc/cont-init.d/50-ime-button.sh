#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename "$0"): $*"
}

NOVNC_INDEX="/opt/noVNC/index.html"

# Check if index.html exists
if [ ! -f "$NOVNC_INDEX" ]; then
    log "noVNC index.html not found, skipping IME button injection."
    exit 0
fi

# Check if we already injected the IME button
if grep -q "noVNC_ime_button" "$NOVNC_INDEX"; then
    log "IME button already injected, skipping."
    exit 0
fi

log "Injecting IME toggle button into noVNC..."

# Find the keyboard button and add IME button after it
# The keyboard button has id="noVNC_keyboard_button"
sed -i 's|<button type="button" class="btn noVNC_hidden" id="noVNC_keyboard_button"|<button type="button" class="btn" id="noVNC_ime_button" title="Toggle Input Method (Ctrl+Space)">\n                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16">\n                                    <path d="M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4.414a1 1 0 0 0-.707.293L.854 15.146A.5.5 0 0 1 0 14.793V2zm5 4a1 1 0 1 0-2 0 1 1 0 0 0 2 0zm4 0a1 1 0 1 0-2 0 1 1 0 0 0 2 0zm3 1a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm-8 2a1 1 0 1 0 0 2h6a1 1 0 1 0 0-2H4z"/>\n                                </svg>\n                            </button>\n                            <button type="button" class="btn noVNC_hidden" id="noVNC_keyboard_button"|' "$NOVNC_INDEX"

# Add JavaScript handler for the IME button
# Inject before the closing </body> tag
sed -i 's|</body>|<script>\n    document.addEventListener("DOMContentLoaded", function() {\n        var imeButton = document.getElementById("noVNC_ime_button");\n        if (imeButton) {\n            imeButton.addEventListener("click", function() {\n                // Access the RFB object from the UI module\n                if (typeof UI !== "undefined" \&\& UI.rfb) {\n                    // Send Ctrl+Space key combination\n                    UI.rfb.sendKey(0xffe3, "ControlLeft", true);  // Ctrl down\n                    UI.rfb.sendKey(0x0020, "Space", true);        // Space down\n                    UI.rfb.sendKey(0x0020, "Space", false);       // Space up\n                    UI.rfb.sendKey(0xffe3, "ControlLeft", false); // Ctrl up\n                    console.log("IME toggle: Ctrl+Space sent");\n                } else {\n                    console.error("RFB not available");\n                }\n            });\n        }\n    });\n</script>\n</body>|' "$NOVNC_INDEX"

log "IME toggle button injected successfully."
