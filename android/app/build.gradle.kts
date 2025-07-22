import java.util.Properties
import java.io.FileInputStream
import java.io.File // Pastikan import ini ada

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Mendefinisikan properti sebagai variabel untuk kemudahan akses dan keamanan
// Penting: Pastikan nilai-nilai ini tidak null sebelum digunakan di signingConfigs
val MYAPP_RELEASE_STORE_FILE: String? = keystoreProperties.getProperty("storeFile")
val MYAPP_RELEASE_STORE_PASSWORD: String? = keystoreProperties.getProperty("storePassword")
val MYAPP_RELEASE_KEY_ALIAS: String? = keystoreProperties.getProperty("keyAlias")
val MYAPP_RELEASE_KEY_PASSWORD: String? = keystoreProperties.getProperty("keyPassword")

android {
    namespace = "com.adultmen.scentify"
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
        applicationId = "com.adultmen.scentify1"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- BLOK YANG DIPERBAIKI ---
    signingConfigs {
        // Gunakan 'create("nama_konfigurasi") { ... }' untuk mendefinisikan konfigurasi penandatanganan
        create("release") { // <-- Perbaikan: Gunakan 'create("release") {'
            // Perbaikan: Gunakan operator '=' untuk assignment
            // Perbaikan: Gunakan double quotes "" untuk string literal
            if (MYAPP_RELEASE_STORE_FILE != null) { // <-- Perbaikan: Menggunakan double quotes
                storeFile = file(MYAPP_RELEASE_STORE_FILE) // <-- Perbaikan: Gunakan '=' dan fungsi 'file()'
            }
            storePassword = MYAPP_RELEASE_STORE_PASSWORD // <-- Perbaikan: Gunakan '='
            keyAlias = MYAPP_RELEASE_KEY_ALIAS // <-- Perbaikan: Gunakan '='
            keyPassword = MYAPP_RELEASE_KEY_PASSWORD // <-- Perbaikan: Gunakan '='
        }
    }

    buildTypes {
        release {
            // Perbaikan: Tautkan ke konfigurasi 'release' yang baru saja dibuat
            signingConfig = signingConfigs.getByName("release") // <-- Perbaikan: Ganti "debug" menjadi "release"
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    // --- AKHIR BLOK YANG DIPERBAIKI ---
}

flutter {
    source = "../.."
}