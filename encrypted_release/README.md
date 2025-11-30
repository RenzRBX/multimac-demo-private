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
