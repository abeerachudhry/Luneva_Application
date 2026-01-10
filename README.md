# Luneva (Flutter)
PCOS wellness & fitness app — splash screen + Firebase Authentication + professional login/signup UI.

What this deliverable includes:
- Splash screen with fade+scale animation (3 seconds).
- Email & password authentication using Firebase Auth.
- Sign-up stores user details in Cloud Firestore: uid, name, email, age, createdAt.
- Professional, consistent purple & white UI. Material 3 enabled.
- Clean project structure and isolated AuthService.

Required Firebase setup (you must do this before running):
1. Install FlutterFire CLI:
   - dart pub global activate flutterfire_cli
2. From your project root run:
   - flutterfire configure
   This generates `lib/firebase_options.dart` tailored to your Firebase project and platforms.
3. Uncomment the import line in `lib/main.dart`:
   - import 'firebase_options.dart';
   And initialize Firebase with:
   - await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   OR if you prefer using platform files add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and leave `Firebase.initializeApp()` as-is.

Android notes:
- Make sure `minSdkVersion` >= 21 in `android/app/build.gradle`.

iOS notes:
- Ensure platform is iOS 11+ and you have the correct plist registered.

Run:
- flutter pub get
- flutter run

Important:
- This module focuses exclusively on splash + auth + login/signup UI per your instructions.
- No onboarding, no dashboard features beyond a simple placeholder, no chat/diet planner.

If you'd like, I can:
- Add the generated firebase_options.dart integration for you if you provide the firebase config.
- Replace the Text-based logo with an asset (provide logo file).
- Add unit tests for AuthService.