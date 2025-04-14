import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:reto_admin/views/main_screen.dart';

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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: MainScreen(),
      builder:
          EasyLoading.init(), //We can now use this EasyLoading anywhere in our entire Web App
    );
  }
}
