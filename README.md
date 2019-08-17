# Flutter Build Environment

A Flutter build environment, to aide in CI/CD workflows.

> NOTE: Currently only works with Android

## Components

- Android SDK (API 29)
- Gradle
- Flutter
- Ruby (for Fastlane)

## Use

> NOTE: Add below to your gradle build repositories (if unable to resolve artifacts)
```
maven {
    url 'https://dl.google.com/dl/android/maven2'
}
```

## Credit

Inspired by [AndroidSDK](https://hub.docker.com/r/thyrlian/android-sdk)
