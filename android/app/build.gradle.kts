import java.util.Properties // This must be the first line

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mittiai.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String?
            keyPassword = keyProperties["keyPassword"] as String?
            if (keyProperties.containsKey("storeFile")) {
                storeFile = rootProject.file(keyProperties["storeFile"] as String)
            }
            storePassword = keyProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "com.mittiai.app"
        minSdk = 23 // Changed from flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName // Changed from hardcoded "1.0.1"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // WorkManager runtime (KTX version) required for androidx.work.impl.WorkManagerInitializer
    implementation("androidx.work:work-runtime-ktx:2.8.1")
}
