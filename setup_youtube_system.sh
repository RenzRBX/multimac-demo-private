#!/bin/bash

# Setup YouTube Key System
# Configure your YouTube channel URL

echo "🎬 YouTube Key System Setup"
echo "============================"
echo ""

cd ~/Documents/MultiMac-Demo

# Get YouTube channel URL
echo "Enter your YouTube channel URL:"
echo "Example: https://youtube.com/@YourChannel"
read -p "Channel URL: " YOUTUBE_URL

# Get specific video URL (optional)
echo ""
echo "Enter a specific video URL (optional, press Enter to skip):"
echo "Example: https://youtube.com/watch?v=ABC123"
read -p "Video URL: " VIDEO_URL

if [ -z "$VIDEO_URL" ]; then
    VIDEO_URL="$YOUTUBE_URL"
fi

# Update custom_key_system.py
echo ""
echo "📝 Updating custom_key_system.py..."

sed -i '' "s|self.youtube_channel = \".*\"|self.youtube_channel = \"$YOUTUBE_URL\"|g" custom_key_system.py

if [ ! -z "$VIDEO_URL" ]; then
    sed -i '' "s|self.youtube_video = \".*\"|self.youtube_video = \"$VIDEO_URL\"|g" custom_key_system.py
fi

echo "✅ YouTube URLs configured!"
echo ""

# Test the system
echo "🧪 Testing key system..."
python3 -c "from custom_key_system import CustomKeySystem; k = CustomKeySystem(); print(f'Channel: {k.youtube_channel}')"

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Test locally: python3 youtube_key_dialog.py"
echo "   2. If it works: ./build_app.sh"
echo "   3. Push to GitHub: git add . && git commit -m 'Add YouTube key system' && git push"
echo ""
echo "🎬 Users will:"
echo "   • Install your app"
echo "   • Subscribe to: $YOUTUBE_URL"
echo "   • Get 24-hour keys automatically!"
echo ""