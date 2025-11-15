# TrizyFlutterShoppingApp Setup Instructions

This Flutter shopping application was cloned and prepared for running. Here's what has been done:

1. Repository cloned from https://github.com/demirelarda/TrizyFlutterShoppingApp
2. Dependencies installed with `flutter pub get`
3. Build runner executed to generate necessary code files
4. A .env file created with a placeholder Stripe key

## To run the application:

### Prerequisites:
- Have a mobile device connected (Android or iOS)
- Ensure Flutter is properly set up on your system
- Have the necessary mobile development tools installed (Android Studio, Xcode)

### Steps:
1. Make sure your mobile device is connected and visible in `flutter devices`
2. Run the application with:
   ```bash
   flutter run
   ```
   or target a specific device:
   ```bash
   flutter run -d <device-id>
   ```

### Note about web and desktop:
Due to the project's dependency on SQLite with FFI (Foreign Function Interface), it cannot run on web browsers or desktop platforms. The application is designed specifically for mobile platforms.

### Required .env file:
A .env file was created with a placeholder Stripe key. For full functionality, replace the placeholder key with a real Stripe publishable key:
```
STRIPE_PUBLISHABLE_KEY=your_real_stripe_key_here
```