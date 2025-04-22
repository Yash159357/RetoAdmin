import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:reto_admin/views/main_screen.dart';
import 'package:reto_admin/views/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //This line ensures that all our Flutter Widgets have been initialized successfully before initialising Firebase.

  //Initialising Firebase
  await Firebase.initializeApp(
    options:
        kIsWeb || Platform.isAndroid
            ? FirebaseOptions(
              //This basically checks whether we are on Web or Android App
              apiKey:
                  "AIzaSyCFQ-cA2ZCcNxK3L-fePb-ABnLCno_AzYA", //Getting all these Firebase Options from Firebase when I was registering or linking this Web App with my Firebase.
              appId: "1:599441118761:web:1f751f3e1d71115b26ee38",
              messagingSenderId: "599441118761",
              projectId: "retoradiance-test",
              storageBucket: "retoradiance-test.firebasestorage.app",
            )
            : null,
  ); //If we are on Web App run all these Firebase Options else 'null'.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reto Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: AuthenticationWrapper(),
      builder: EasyLoading.init(), //We can now use this EasyLoading anywhere in our entire Web App
    );
  }
}

// This widget will handle the authentication state
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to listen to authentication state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while connection state is waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If the snapshot has a user, they're logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }
        
        // If no user, show the auth screen
        return const AdminAuthScreen();
      },
    );
  }
}