# timetable_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources used for getting started from scratch:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

- [online documentation](https://docs.flutter.dev/) - for tutorials and full API references

## Build Instructions

### Prerequisites

⚠️ **Important**: This project requires **Android NDK version 27** as it is hardcoded in the configuration. Make sure you have NDK 27 installed before building.

📁 **NDK Configuration Location**: The NDK version is specified in `android/app/build.gradle`. If you need to change the NDK version, modify this file accordingly.

### Setup

1. Ensure you have Flutter installed and configured
2. Install Android NDK version 27 through Android Studio SDK Manager or download directly
3. Set the NDK path in your local environment

### Building the Project

1. Get dependencies:
   ```bash
   flutter pub get
   ```

2. For Android:
   ```bash
   flutter build apk
   ```
   Or for release:
   ```bash
   flutter build apk --release
   ```

3. For iOS (if applicable):
   ```bash
   flutter build ios
   ```

### Running the Project

```bash
flutter run
```

Make sure you have an emulator running or a physical device connected.
"# timetable_app_project" 
