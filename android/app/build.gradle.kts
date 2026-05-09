plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = run {
    val properties = mutableMapOf<String, String>()
    val propertiesFile = rootProject.file("local.properties")
    if (propertiesFile.exists()) {
        propertiesFile.readLines().forEach { line ->
            if (line.contains("=") && !line.startsWith("#")) {
                val key = line.substringBefore("=").trim()
                val value = line.substringAfter("=").trim()
                properties[key] = value
            }
        }
    }
    properties
}

val flutterVersionCode = localProperties["flutter.versionCode"] ?: "1"
val flutterVersionName = localProperties["flutter.versionName"] ?: "1.0"

android {
    namespace = "com.nanzo.theme"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.nanzo.theme"
        minSdk = 24
        targetSdk = 35
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
}
