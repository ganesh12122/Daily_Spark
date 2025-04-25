buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Add this to fix namespace issues in all subprojects
    afterEvaluate {
        if (project.hasProperty("android")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                namespace = when (project.name) {
                    "app" -> "com.example.spakvowbackup"
                    "flutter_native_timezone" -> "com.baseflow.flutternativetimezone"
                    else -> "com.example.${project.name}"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}