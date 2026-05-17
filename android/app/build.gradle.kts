plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.kangleiinnovations.maruppay"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.kangleiinnovations.maruppay"
        minSdk = flutter.minSdkVersion // Required for Firebase/Google Sign-In
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
tasks.withType<JavaCompile> {
    options.compilerArgs.add("-Xlint:-options")
}
dependencies {
    // Flutter plugins handle their own Firebase dependencies.
    // We only need the BoM for version alignment if we use native code.
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
}

flutter {
    source = "../.."
}
