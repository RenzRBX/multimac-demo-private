#!/bin/bash

# MultiMac Demo - .app Bundle Builder
# Creates encrypted macOS .app bundle for distribution

set -e

echo "🍎 MultiMac Demo - .app Bundle Builder"
echo "========================================"
echo ""

# Configuration
PROJECT_DIR="$(pwd)"
APP_NAME="MultiMac Demo"
APP_BUNDLE="$PROJECT_DIR/MultiMac Demo.app"
DIST_DIR="$PROJECT_DIR/dist_app"
ENCRYPTED_DIR="$PROJECT_DIR/encrypted_release"
BUILD_VERSION="1.0.0"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$APP_BUNDLE" "$DIST_DIR" "$ENCRYPTED_DIR"
rm -rf build dist *.spec

# Step 1: Obfuscate Python code
echo ""
echo "🔒 Step 1: Obfuscating Python source code..."
mkdir -p "$DIST_DIR/obfuscated"

pyarmor gen --recursive \
    --output "$DIST_DIR/obfuscated" \
    --platform darwin.x86_64 \
    --platform darwin.arm64 \
    *.py

echo "✓ Code obfuscated"

# Step 2: Create .app bundle structure
echo ""
echo "📦 Step 2: Creating .app bundle structure..."

mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
mkdir -p "$APP_BUNDLE/Contents/Frameworks"

# Copy obfuscated Python files
echo "  → Copying obfuscated files..."
cp -r "$DIST_DIR/obfuscated/"* "$APP_BUNDLE/Contents/Resources/"

# Copy all project directories
echo "  → Copying project files..."
for dir in ui core security assets; do
    if [ -d "$dir" ]; then
        echo "    → $dir/"
        cp -r "$dir" "$APP_BUNDLE/Contents/Resources/"
    fi
done

# Copy dependencies
cp requirements.txt "$APP_BUNDLE/Contents/Resources/"
[ -f config.py ] && cp config.py "$APP_BUNDLE/Contents/Resources/" || true

# Step 3: Create launcher script
echo ""
echo "📝 Step 3: Creating launcher script..."

cat > "$APP_BUNDLE/Contents/MacOS/MultiMac" << 'LAUNCHER_EOF'
#!/bin/bash

# MultiMac Demo Launcher
APP_DIR="$(cd "$(dirname "$0")/../Resources" && pwd)"
cd "$APP_DIR"

# Check if venv exists, create if not
if [ ! -d "$APP_DIR/venv" ]; then
    echo "🔧 First-time setup..."
    
    # Find Python 3.11
    if [ -x "/opt/homebrew/bin/python3.11" ]; then
        PYTHON="/opt/homebrew/bin/python3.11"
    elif [ -x "/usr/local/bin/python3.11" ]; then
        PYTHON="/usr/local/bin/python3.11"
    elif command -v python3.11 &> /dev/null; then
        PYTHON="python3.11"
    else
        osascript -e 'display dialog "Python 3.11 required!\n\nInstall with:\nbrew install python@3.11" buttons {"OK"} default button 1 with icon stop'
        exit 1
    fi
    
    # Create venv
    "$PYTHON" -m venv "$APP_DIR/venv"
    source "$APP_DIR/venv/bin/activate"
    
    # Install dependencies
    pip install --upgrade pip -q
    pip install -r "$APP_DIR/requirements.txt" -q
else
    source "$APP_DIR/venv/bin/activate"
fi

# Launch app
cd "$APP_DIR"
python3 main.py

LAUNCHER_EOF

chmod +x "$APP_BUNDLE/Contents/MacOS/MultiMac"

# Step 4: Create Info.plist
echo ""
echo "📄 Step 4: Creating Info.plist..."

cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>MultiMac</string>
    <key>CFBundleIdentifier</key>
    <string>com.multimac.demo</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>MultiMac Demo</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
PLIST_EOF

# Step 5: Add app icon (if exists)
if [ -f "assets/app_icon.icns" ]; then
    echo "  → Adding app icon..."
    cp "assets/app_icon.icns" "$APP_BUNDLE/Contents/Resources/"
    echo "    <key>CFBundleIconFile</key>" >> "$APP_BUNDLE/Contents/Info.plist.tmp"
    echo "    <string>app_icon.icns</string>" >> "$APP_BUNDLE/Contents/Info.plist.tmp"
fi

echo "✓ .app bundle created"

# Step 6: Create encrypted DMG
echo ""
echo "🔐 Step 5: Creating encrypted archive..."
mkdir -p "$ENCRYPTED_DIR"

# Create compressed tar of the .app
echo "  → Compressing .app bundle..."
tar -czf "$ENCRYPTED_DIR/multimac-demo.app.tar.gz" -C "$PROJECT_DIR" "MultiMac Demo.app"

# Encrypt with AES-256
echo ""
echo "🔑 Enter encryption passphrase:"
openssl enc -aes-256-cbc -pbkdf2 -salt \
    -in "$ENCRYPTED_DIR/multimac-demo.app.tar.gz" \
    -out "$ENCRYPTED_DIR/multimac-demo.app.tar.gz.enc"

rm "$ENCRYPTED_DIR/multimac-demo.app.tar.gz"
echo "✓ Archive encrypted"

# Step 6: Create installer script
echo ""
echo "📝 Step 6: Creating installer script..."

cat > "$ENCRYPTED_DIR/install-multimac.sh" << 'INSTALL_EOF'
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
INSTALL_EOF

chmod +x "$ENCRYPTED_DIR/install-multimac.sh"

# Step 7: Create README
cat > "$ENCRYPTED_DIR/README.md" << 'README_EOF'
# MultiMac Demo - macOS App Distribution

## Quick Install

### One-line installer (recommended):
```bash
curl -fsSL https://raw.githubusercontent.com/RenzRBX/multimac-demo-private/main/encrypted_release/install-multimac.sh | bash
```

Then enter the passphrase when prompted (provided separately).

### Manual Installation:
1. Download `multimac-demo.app.tar.gz.enc`
2. Decrypt:
   ```bash
   openssl enc -d -aes-256-cbc -pbkdf2 \
     -in multimac-demo.app.tar.gz.enc | tar -xz -C /Applications
   ```
3. Open: `Applications/MultiMac Demo.app`

## Requirements
- macOS 11.0 or later
- Homebrew (auto-installed)
- Python 3.11 (auto-installed)

## Security
✅ AES-256 encryption  
✅ PyArmor code obfuscation  
✅ Private GitHub distribution  
✅ Separate passphrase delivery

## Support
GitHub: https://github.com/RenzRBX/multimac-demo-private
README_EOF

# Generate checksums
cd "$ENCRYPTED_DIR"
shasum -a 256 multimac-demo.app.tar.gz.enc > checksums.txt

echo ""
echo "========================================"
echo "✅ Build Complete!"
echo "========================================"
echo ""
echo "📂 Created files:"
echo "   • MultiMac Demo.app (in current directory)"
echo "   • encrypted_release/multimac-demo.app.tar.gz.enc"
echo ""
echo "📦 Distribution files:"
ls -lh "$ENCRYPTED_DIR"
echo ""
echo "🧪 Test the .app locally:"
echo "   open 'MultiMac Demo.app'"
echo ""
echo "📤 Next steps:"
echo "   1. Test the .app bundle works"
echo "   2. Push to GitHub:"
echo "      git add encrypted_release/"
echo "      git commit -m 'Add .app bundle distribution'"
echo "      git push"
echo ""
echo "🔑 Share passphrase separately via secure channel!"
echo ""