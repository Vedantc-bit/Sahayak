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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    afterEvaluate {
        // Fix for Isar namespace issue in Gradle 8+
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val baseExt = android as com.android.build.gradle.BaseExtension
                if (baseExt.namespace == null) {
                    baseExt.namespace = group.toString()
                }
            } catch (e: Exception) {
                // Ignore casting errors
            }
        }
    }
}