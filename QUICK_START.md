# 🚀 Quick Start - Google Play Publishing

## ✅ What's Already Done

1. **Keystore Created**: `~/upload-keystore.jks` with alias `upload`
2. **Build Configuration**: Updated `android/app/build.gradle.kts` with signing config
3. **Security**: Added keystore files to `.gitignore`
4. **Disk Space**: Freed up 20GB for builds

## 🔧 Next Steps (Run These Commands)

### 1. Set Your Keystore Passwords
```bash
./update_keystore_passwords.sh
```
*This will securely update the key.properties file with your actual passwords*

### 2. Test the Build
```bash
flutter build appbundle --release
```
*This should create: `build/app/outputs/bundle/release/app-release.aab`*

### 3. Verify the AAB
```bash
# Check if AAB was created
ls -la build/app/outputs/bundle/release/

# Optional: Check AAB info
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks --mode=universal
```

## 📱 Google Play Console Setup

1. **Go to**: [Play Console](https://play.google.com/console)
2. **Create App**: Set name, type, free/paid
3. **Upload AAB**: Use the generated `app-release.aab`
4. **Complete Required Pages**:
   - Data Safety (mandatory)
   - Store Listing (screenshots, descriptions, icons)
   - Pricing & Distribution
   - Content Rating

## 🔒 Security Reminders

- **Keystore Location**: `~/upload-keystore.jks`
- **Backup**: Copy keystore to secure location
- **Passwords**: Store in password manager
- **Never commit**: `key.properties` or `.jks` files

## 🆘 If Build Fails

1. **Check passwords**: Run `./update_keystore_passwords.sh` again
2. **Clean build**: `flutter clean && flutter build appbundle --release`
3. **Check target SDK**: Ensure it's >= 34 (preferably 35)

## 📋 Checklist

- [ ] Run password setup script
- [ ] Test AAB build
- [ ] Create Play Console app
- [ ] Upload AAB to internal testing
- [ ] Complete store listing
- [ ] Submit for review

**Ready to go!** 🎯
