plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.forensic_system"
    compileSdk = 36 // Updated to 36 as required by dependencies
    
    // Let Gradle use the default installed version to avoid InstallFailedException
    // ndkVersion = flutter.ndkVersion 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.forensic_system"
        minSdk = flutter.minSdkVersion
        targetSdk = 36 // Updated to match compileSdk for consistency
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
