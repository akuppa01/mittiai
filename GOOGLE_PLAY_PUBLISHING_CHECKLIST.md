# Google Play Store Publishing Checklist

## Quick Prerequisites ✅
1. Play Console account ($25 paid)
2. Mac with working Flutter project
3. JDK 11+ installed
4. Android SDK & command line tools
5. App metadata ready (name, descriptions, screenshots, icons, privacy policy)

---

## A. Decide Which Build to Upload

- **New app**: Upload any valid signed AAB
- **Existing app**: Must control upload key (keystore) or transfer app ownership
- **Package name conflict**: Transfer app or use same developer account

---

## B. Generate Your Own Signed AAB (Recommended)

### B1. Create Upload Keystore (One-time)

```bash
# Run from your home directory
keytool -genkeypair -v \
  -keystore ~/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

**⚠️ IMPORTANT**: Save keystore path, alias, and passwords securely!

### B2. Configure Flutter Signing

Create `android/key.properties`:
```properties
storeFile=/Users/adi/upload-keystore.jks
storePassword=your_keystore_password
keyAlias=upload
keyPassword=your_key_password
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### B3. Build Signed AAB

**Option 1: Flutter Command (Recommended)**
```bash
# From project root
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**Option 2: Android Studio GUI**
1. Open `android/` folder in Android Studio
2. Build > Generate Signed Bundle/APK
3. Choose Android App Bundle
4. Select keystore and follow wizard

**Option 3: Gradle Command**
```bash
# From project root
cd android
./gradlew clean :app:bundleRelease
# Output: app/build/outputs/bundle/release/app-release.aab
```

---

## C. If You Have AAB from Developer

1. **Get the keystore** from developer for future updates
2. **If no keystore**: Can only upload initial release (new apps only)
3. **If package exists elsewhere**: Transfer app ownership in Play Console

---

## D. Create App in Play Console

1. Go to [Play Console](https://play.google.com/console)
2. Home > Create app
3. Set language, app name, type (app/game), free/paid
4. **Package name is fixed** once you upload AAB

---

## E. Required Play Console Pages (Complete All)

### 1. App Content (Data Safety) - MANDATORY
- Complete Data Safety form truthfully
- Required for all apps

### 2. Store Presence / Main Store Listing
- **Short description** (80 chars max)
- **Full description** (4000 chars max)
- **Graphics**:
  - Phone screenshots (min 1, recommended 4-8)
  - 512×512 app icon
  - 1024×500 feature graphic
  - Promo video (optional)

### 3. Pricing & Distribution
- Free vs paid
- Countries/regions
- Content rating questionnaire

### 4. Content Rating
- Complete questionnaire
- Required for all apps

### 5. Ads & Privacy Policy
- Ads declaration
- Privacy policy URL (if collecting data)

### 6. App Signing
- Configure Play App Signing (recommended)
- Google manages app signing for new apps

---

## F. Upload Release (Start with Internal Testing)

### 1. Create Internal Test
1. Release > Testing > Internal testing
2. Create new release
3. Upload your `.aab` file
4. Add release notes
5. Add tester emails or Google Group
6. Get shareable test URL

### 2. Production Release
1. Release > Production > Create new release
2. Upload signed `.aab`
3. Add release notes
4. Review and roll out

---

## G. After Upload

1. **Monitor Play Console inbox** for policy messages
2. **Keep keystore safe** - back it up!
3. **Check for warnings** and fix issues
4. **Staged rollout** recommended for production

---

## Quick Command Cheat Sheet

```bash
# Generate keystore
keytool -genkeypair -v -keystore ~/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000

# Build Flutter AAB
flutter build appbundle --release

# Build with Gradle
cd android && ./gradlew clean :app:bundleRelease

# Check AAB info
bundletool build-apks --bundle=app-release.aab --output=app.apks --mode=universal
```

---

## Troubleshooting

### "Generate Signed Bundle" Grayed Out
- Wait for Gradle sync to finish
- Open `android/` folder in Android Studio
- For Flutter: Use `flutter build appbundle` instead

### "AAB Not Signed" Error
- Ensure AAB is signed with upload key
- Check signing config in `build.gradle`
- Use Android Studio signing wizard

### Target SDK Version Error
- **New apps**: Must target Android 15 (API 35)
- **Updates**: At least API 34
- Update `targetSdkVersion` in `android/app/build.gradle`

---

## Recommended Order Right Now

1. ✅ **Create and backup keystore**
2. ✅ **Check targetSdkVersion >= 35**
3. ✅ **Build signed AAB**
4. ✅ **Create app in Play Console**
5. ✅ **Complete Data Safety form**
6. ✅ **Fill store listing**
7. ✅ **Upload to internal testing first**

---

## Flutter-Specific Notes

- Use `flutter build appbundle --release` for Flutter projects
- Ensure `android/app/build.gradle` has proper signing config
- Test with `flutter install` before building AAB
- Check `pubspec.yaml` for proper version numbers

**Next Step**: Run the keystore generation command and let's get your app ready for Play Store! 🚀
