#!/bin/bash

# MultiMac Demo - Secure Build Script (FIXED)
# Creates encrypted, obfuscated distribution

set -e

echo "🔐 MultiMac Demo - Secure Build Process"
echo "========================================"
echo ""

# Configuration
PROJECT_DIR="$(pwd)"
DIST_DIR="$PROJECT_DIR/dist_secure"
ENCRYPTED_DIR="$PROJECT_DIR/encrypted_release"
BUILD_VERSION="1.0.0-demo"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$DIST_DIR" "$ENCRYPTED_DIR"
rm -rf build dist *.spec

# Step 1: Obfuscate Python code with PyArmor (FIXED - removed --restrict flag)
echo ""
echo "🔒 Step 1: Obfuscating Python source code..."
mkdir -p "$DIST_DIR/obfuscated"

pyarmor gen --recursive \
    --output "$DIST_DIR/obfuscated" \
    --platform darwin.x86_64 \
    --platform darwin.arm64 \
    *.py

echo "✓ Code obfuscated"

# Step 2: Copy obfuscated files and dependencies
echo ""
echo "📦 Step 2: Copying files..."
cp -r "$DIST_DIR/obfuscated/"* "$DIST_DIR/" 2>/dev/null || true
rm -rf "$DIST_DIR/obfuscated"

# Copy ALL necessary directories and files
echo "📦 Copying project files..."
cp requirements.txt "$DIST_DIR/"

# Copy all directories (ui, core, security, etc.)
for dir in ui core security assets; do
    if [ -d "$dir" ]; then
        echo "  → Copying $dir/"
        cp -r "$dir" "$DIST_DIR/"
    fi
done

# Copy config files
for file in config.py Info.plist entitlements.plist; do
    if [ -f "$file" ]; then
        echo "  → Copying $file"
        cp "$file" "$DIST_DIR/"
    fi
done

# Step 3: Create installer script
echo ""
echo "📝 Step 3: Creating installer script..."
cat > "$DIST_DIR/install.sh" << 'EOF'
#!/bin/bash

echo "🚀 MultiMac Demo - Installation"
echo "==============================="
echo ""

# Check macOS version
if [[ $(sw_vers -productVersion | cut -d. -f1) -lt 11 ]]; then
    echo "❌ Error: macOS 11.0 (Big Sur) or later required"
    exit 1
fi

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo "📥 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Python 3.11
if ! command -v /opt/homebrew/bin/python3.11 &> /dev/null; then
    echo "🐍 Installing Python 3.11..."
    brew install python@3.11 python-tk@3.11
fi

# Create venv
echo "📦 Setting up environment..."
/opt/homebrew/bin/python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip -q
pip install -r requirements.txt -q

echo ""
echo "✅ Installation complete!"
echo ""
echo "To run MultiMac Demo:"
echo "  cd $(pwd)"
echo "  source venv/bin/activate"
echo "  python3 main.py"
echo ""
EOF

chmod +x "$DIST_DIR/install.sh"

# Step 4: Create encrypted archive
echo ""
echo "🔐 Step 4: Creating encrypted archive..."
mkdir -p "$ENCRYPTED_DIR"

# Create tar archive
cd "$DIST_DIR"
tar -czf "$ENCRYPTED_DIR/multimac-demo.tar.gz" .
cd "$PROJECT_DIR"

# Encrypt with OpenSSL (most compatible)
echo ""
echo "🔑 Enter encryption passphrase (share this with users):"
openssl enc -aes-256-cbc -pbkdf2 -salt \
    -in "$ENCRYPTED_DIR/multimac-demo.tar.gz" \
    -out "$ENCRYPTED_DIR/multimac-demo.tar.gz.enc"
rm "$ENCRYPTED_DIR/multimac-demo.tar.gz"

echo "✓ Archive encrypted"

# Step 5: Create installation script for users
cat > "$ENCRYPTED_DIR/install-multimac.sh" << 'INSTALL_EOF'
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
INSTALL_EOF

chmod +x "$ENCRYPTED_DIR/install-multimac.sh"

# Step 6: Create README
cat > "$ENCRYPTED_DIR/README.md" << 'README_EOF'
# MultiMac Demo - Encrypted Distribution

This package contains an encrypted version of MultiMac Demo.

## Installation

### Method 1: One-line installer (recommended)
```bash
curl -fsSL YOUR_GITHUB_RAW_URL/install-multimac.sh | bash
```

### Method 2: Manual installation
1. Download: `multimac-demo.tar.gz.enc`
2. Decrypt with provided passphrase:
   ```bash
   openssl enc -d -aes-256-cbc -pbkdf2 \
     -in multimac-demo.tar.gz.enc | tar -xz
   ```
3. Run `install.sh`

## Requirements
- macOS 11.0 or later
- Internet connection
- Decryption passphrase (provided separately)

## Security Features
✅ AES-256 encryption
✅ Code obfuscation with PyArmor
✅ Private distribution
✅ Separate passphrase delivery

## Support
GitHub: https://github.com/YOUR_USERNAME/multimac-demo
README_EOF

# Generate checksums
cd "$ENCRYPTED_DIR"
shasum -a 256 multimac-demo.tar.gz.enc > checksums.txt

echo ""
echo "========================================"
echo "✅ Build Complete!"
echo "========================================"
echo ""
echo "📂 Distribution files:"
ls -lh "$ENCRYPTED_DIR"
echo ""
echo "📤 Next steps:"
echo "   1. Create private GitHub repository"
echo "   2. Upload encrypted_release/* to repo"
echo "   3. Update install-multimac.sh with your GitHub URL"
echo "   4. Share curl command + passphrase separately"
echo ""
echo "🔑 SECURITY TIP: Share passphrase via secure channel (SMS/Discord DM)"
echo ""