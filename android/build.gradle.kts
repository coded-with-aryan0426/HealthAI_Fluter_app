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
    apply(from = rootProject.file("namespace_fix.gradle"))

    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("2.2.0")
            }
        }
    }

    // Force all subprojects (e.g. isar_flutter_libs) to compile against SDK 36
    // so android:attr/lStar (added in API 31/Material3) is always found.
      afterEvaluate {
          val androidExtension = extensions.findByName("android")
            if (androidExtension is com.android.build.gradle.LibraryExtension) {
                androidExtension.compileSdk = 36
                androidExtension.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                androidExtension.compileOptions.targetCompatibility = JavaVersion.VERSION_17
            }
            // Suppress obsolete source/target 8 warnings from Java compilation tasks
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = JavaVersion.VERSION_17.toString()
                targetCompatibility = JavaVersion.VERSION_17.toString()
                options.compilerArgs.addAll(listOf("-Xlint:-options"))
            }
              // Align Kotlin jvmTarget with Java target to avoid JVM compatibility mismatch
              tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
                  compilerOptions {
                      jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                  }
              }
      }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
