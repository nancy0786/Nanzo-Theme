pluginManagement {
    val flutterSdkPath = run {
        val propertiesFile = file("local.properties")
        if (propertiesFile.exists()) {
            propertiesFile.readLines()
                .find { it.startsWith("flutter.sdk=") }
                ?.substringAfter("=")
                ?.trim()
        } else {
            System.getenv("FLUTTER_ROOT")
        }
    } ?: error("flutter.sdk not set in local.properties and FLUTTER_ROOT environment variable not found. This is required to locate the Flutter SDK.")

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false
}

include(":app")
