#!/bin/bash

echo "🍎 MultiMac Demo - .app Installer"
echo "===================================="
echo ""

REPO_URL="https://raw.githubusercontent.com/RenzRBX/multimac-demo-private/main/encrypted_release"
INSTALL_DIR="/Applications"

# Check macOS version
if [[ $(sw_vers -productVersion | cut -d. -f1) -lt 11 ]]; then
    echo "❌ Error: macOS 11.0 (Big Sur) or later required"
    exit 1
fi

# Check Homebrew
echo "🔍 Checking dependencies..."
if ! command -v brew &> /dev/null; then
    echo "📥 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Python 3.11 and Tcl/Tk
if ! command -v /opt/homebrew/bin/python3.11 &> /dev/null; then
    echo "🐍 Installing Python 3.11..."
    brew install python@3.11 python-tk@3.11
fi

# Download encrypted .app
echo ""
echo "📥 Downloading MultiMac Demo.app..."
curl -L -o /tmp/multimac-demo.app.enc \
    "${REPO_URL}/multimac-demo.app.tar.gz.enc"

if [ ! -f /tmp/multimac-demo.app.enc ]; then
    echo "❌ Download failed"
    exit 1
fi

# Decrypt and extract
echo ""
echo "🔓 Enter decryption passphrase:"
openssl enc -d -aes-256-cbc -pbkdf2 \
    -in /tmp/multimac-demo.app.enc | tar -xz -C "$INSTALL_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Decryption failed - incorrect passphrase"
    rm /tmp/multimac-demo.app.enc
    exit 1
fi

# Cleanup
rm /tmp/multimac-demo.app.enc

echo ""
echo "✅ Installation complete!"
echo ""
echo "MultiMac Demo.app installed to: $INSTALL_DIR/MultiMac Demo.app"
echo ""
echo "🚀 To launch:"
echo "   • Open Finder → Applications → MultiMac Demo"
echo "   • Or run: open '$INSTALL_DIR/MultiMac Demo.app'"
echo ""
