buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.4'; // Gunakan versi terbaru
        classpath 'com.google.gms:google-services:4.3.15'; // Tetap diperlukan untuk Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}