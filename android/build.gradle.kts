allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Force Java tasks to use JVM target byte-code format 17
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }

    // Force Kotlin tasks using ultra-modern compilerOptions DSL to match on JVM 17
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    // Force all Flutter plugin subprojects to compile against Android SDK 36
    // and resolve Agora namespace collisions on AGP 8+
    afterEvaluate {
        if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
            configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(36)

                // Fix duplicate 'io.agora.rtc' namespace across Agora modules
                if (project.name.contains("iris") || project.name.contains("agora")) {
                    if (namespace == "io.agora.rtc") {
                        namespace = "io.agora.rtc.iris"
                    }
                }
            }
        }
    }
}

// THIS MUST COME AFTER subprojects with afterEvaluate
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}