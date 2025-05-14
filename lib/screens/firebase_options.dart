import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDLRRYfaefe7Fw66UpvwvDPz3FrbQeIfAw', // Replace with your API key
      appId: '1:934307901345:web:23e70e10883f669d0365e0', // Replace with your App ID
      messagingSenderId: '934307901345', // Replace with your Sender ID
      projectId: 'superapp-101c1', // Replace with your Project ID
      storageBucket: 'superapp-101c1.firebasestorage.app', // Optional: Replace with your Storage Bucket
      authDomain: 'superapp-101c1.firebaseapp.com', // Optional: Replace with your Auth Domain (for Web)
      measurementId: 'G-TC81FT6G60', // Optional: Replace with your Measurement ID (for Web)
    );
  }
}
