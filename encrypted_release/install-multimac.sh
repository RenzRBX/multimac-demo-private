#!/bin/bash

echo "🔐 MultiMac Demo - Secure Installer"
echo "===================================="
echo ""

INSTALL_DIR="$HOME/MultiMac-Demo"
REPO_URL="YOUR_GITHUB_RAW_URL"

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download encrypted package
echo "📥 Downloading MultiMac Demo..."
curl -L -o /tmp/multimac-demo.enc \
    "${REPO_URL}/multimac-demo.tar.gz.enc"

if [ ! -f /tmp/multimac-demo.enc ]; then
    echo "❌ Download failed"
    exit 1
fi

# Decrypt
echo ""
echo "🔓 Enter decryption passphrase:"
openssl enc -d -aes-256-cbc -pbkdf2 \
    -in /tmp/multimac-demo.enc | tar -xz -C "$INSTALL_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Decryption failed - incorrect passphrase"
    rm /tmp/multimac-demo.enc
    exit 1
fi

# Cleanup
rm /tmp/multimac-demo.enc

# Run installer
cd "$INSTALL_DIR"
bash install.sh

echo ""
echo "✅ MultiMac Demo installed to: $INSTALL_DIR"
