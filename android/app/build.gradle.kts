plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.interview_pro_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // Original application ID
        applicationId = "com.example.interview_pro_app"
        
        // Optimized SDK versions for production
        minSdk = flutter.minSdkVersion  // Android 5.0 (API level 21) for broader compatibility
        targetSdk = 34  // Latest stable Android API
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // App metadata for production
        resValue("string", "app_name", "InterviewPro")
        
        // Performance optimizations
        multiDexEnabled = true
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }
        
        release {
            // Production release configuration
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Code obfuscation and optimization
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // TODO: Configure proper signing for production release
            // For now, using debug keys for development builds
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Build optimization
    buildFeatures {
        buildConfig = true
    }
    
    // Packaging options for production
    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
    
    // Lint options for production quality
    lint {
        checkReleaseBuilds = true
        abortOnError = false
        warningsAsErrors = false
    }
}

flutter {
    source = "../.."
}
