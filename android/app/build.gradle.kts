plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.healthcare_assistant"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.healthcare_assistant"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.1"))
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-analytics")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    implementation("androidx.core:core-ktx:1.15.0")
}

/// --- FIX: Make Flutter detect the APK correctly ---
tasks.register<Copy>("copyDebugApkToFlutter") {

    // AGP 8 uses "packageDebug" instead of "assembleDebug"
    dependsOn("packageDebug")

    val generatedApk = layout.buildDirectory.file("outputs/apk/debug/app-debug.apk")

    from(generatedApk)
    into(layout.projectDirectory.dir("../../build/app/outputs/flutter-apk/"))
}

// After packaging APK, copy to flutter-apk
tasks.matching { it.name == "packageDebug" }.configureEach {
    finalizedBy("copyDebugApkToFlutter")
}