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
