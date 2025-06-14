import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.unaj.culturapp_baires"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.unaj.culturapp_baires"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

android {
    buildFeatures {
        buildConfig = true
    }
}

android {
    defaultConfig {
        buildConfigField("String", "GOOGLE_GEMINI_API_KEY", "\"[REEMPLAZAR]\"")
        buildConfigField("String", "GOOGLE_SEARCH_API_KEY", "\"[REEMPLAZAR]\"")
        buildConfigField("String", "GOOGLE_SEARCH_CX", "\"[REEMPLAZAR]\"")
        buildConfigField("String", "MONGODB_USER", "\"[REEMPLAZAR]\"")
        buildConfigField("String", "MONGODB_PWD", "\"[REEMPLAZAR]\"")
        buildConfigField("String", "MONGODB_SERVER", "\"[REEMPLAZAR]\"")
        buildConfigField("String", "MONGODB_COLLECTION", "\"[REEMPLAZAR]\"")
        buildConfigField("String", "MONGODB_CLUSTER", "\"[REEMPLAZAR]\"")
    }   
}

val keystoreProperties = Properties().apply {
    load(FileInputStream(rootProject.file("key.properties")))
}

android {
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}