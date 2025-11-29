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
