#!/bin/bash

# Script to securely update keystore passwords in key.properties
# Run this script to set your actual keystore passwords

echo "🔐 Keystore Password Setup"
echo "========================="
echo ""
echo "This script will help you set your keystore passwords securely."
echo "You'll need the passwords you entered when creating the keystore."
echo ""

# Read passwords securely
read -s -p "Enter your keystore password: " KEYSTORE_PASSWORD
echo ""
read -s -p "Enter your key password: " KEY_PASSWORD
echo ""

# Update key.properties file
cat > android/key.properties << EOF
storeFile=/Users/adi/upload-keystore.jks
storePassword=$KEYSTORE_PASSWORD
keyAlias=upload
keyPassword=$KEY_PASSWORD
EOF

echo ""
echo "✅ key.properties updated successfully!"
echo ""
echo "🔒 Security Note:"
echo "   - Keep your keystore file safe: ~/upload-keystore.jks"
echo "   - Back up your keystore and passwords"
echo "   - Never commit key.properties to version control"
echo ""
echo "📱 Next steps:"
echo "   1. Test the build: flutter build appbundle --release"
echo "   2. Check the output: build/app/outputs/bundle/release/app-release.aab"
echo "   3. Upload to Google Play Console"
echo ""
