plugins {
    // This is necessary for some projects to properly resolve the google-services plugin
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.android.application") version "8.7.2" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir("../../build").get())

subprojects {
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir(project.name).get())
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
