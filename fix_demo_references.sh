#!/bin/bash

# Fix Demo References Script
# Updates all old GitHub/email references to Demo version

set -e

echo "🔧 Updating references to Demo Version..."
echo "=========================================="

cd ~/Documents/MultiMac-Demo

# Files to update
FILES=(
    "config.py"
    "core/updater.py"
    "ui/tabs/tab_help.py"
)

echo ""
echo "📝 Updating files..."

# 1. Update config.py
echo "  → Updating config.py"
sed -i '' 's|https://github.com/permyoutue2012-source/multi-roblox-launcher|https://github.com/RenzRBX/multimac-demo-private|g' config.py

# 2. Update core/updater.py
echo "  → Updating core/updater.py"
sed -i '' 's|https://github.com/permyoutue2012-source/multi-roblox-launcher|https://github.com/RenzRBX/multimac-demo-private|g' core/updater.py

# Disable update checking for demo
sed -i '' 's|Checks GitHub releases for new versions|Demo version - Update checking disabled|g' core/updater.py
sed -i '' 's|Check if a new version is available|Demo version - Always returns no updates|g' core/updater.py
sed -i '' 's|f"New version {latest_tag} available!\\n"|"Demo Version - Updates disabled\\n"|g' core/updater.py

# Add early return to check_for_updates method
cat > /tmp/updater_patch.py << 'EOF'
    def check_for_updates(self):
        """
        Demo version - Always returns no updates
        """
        # Demo version - disable update checking
        return None
        
        # Original update checking code disabled for demo
        try:
EOF

# Find and replace the check_for_updates method
awk '
/def check_for_updates\(self\):/ {
    print "    def check_for_updates(self):"
    print "        \"\"\""
    print "        Demo version - Always returns no updates"
    print "        \"\"\""
    print "        # Demo version - disable update checking"
    print "        return None"
    print ""
    in_method=1
    next
}
in_method && /^    def / {
    in_method=0
}
!in_method {
    print
}
' core/updater.py > core/updater.py.tmp && mv core/updater.py.tmp core/updater.py

# 3. Update ui/tabs/tab_help.py
echo "  → Updating ui/tabs/tab_help.py"

# Replace GitHub links
sed -i '' 's|https://github.com/permyoutue2012-source/multi-roblox-launcher|https://github.com/RenzRBX/multimac-demo-private|g' ui/tabs/tab_help.py

# Update help text
sed -i '' 's|github.com/permyoutue2012-source/multi-roblox-launcher|github.com/RenzRBX/multimac-demo-private (Demo Version)|g' ui/tabs/tab_help.py
sed -i '' 's|Updates: Check GitHub for new releases|Updates: Disabled for Demo Version|g' ui/tabs/tab_help.py

# Clean up Python cache files
echo ""
echo "🧹 Cleaning Python cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true

echo ""
echo "✅ References updated!"
echo ""
echo "📋 Changes made:"
echo "   • Updated GitHub URLs to your new repo"
echo "   • Disabled update checking for demo"
echo "   • Updated help tab information"
echo "   • Cleaned Python cache files"
echo ""
echo "🔄 Next steps:"
echo "   1. Test the app: source venv/bin/activate && python3 main.py"
echo "   2. Rebuild .app bundle: ./build_app.sh"
echo "   3. Push to GitHub: git add . && git commit -m 'Update to demo version' && git push"
echo ""