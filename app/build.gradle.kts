plugins {
    id("com.android.application")
}

android {
    namespace = "com.fsociety.mrrobotwatchface"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.fsociety.mrrobotwatchface"
        minSdk = 33 // Wear OS 4 (WFF v1) is supported on API 33+
        targetSdk = 34
        versionCode = 40
        versionName = "2.9.1"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Watch Face Format is fully declarative XML.
    // No runtime code execution or Kotlin/Java dependencies needed!
}
