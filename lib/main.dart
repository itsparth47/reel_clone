import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reels/services/authcontroller.dart';
import 'package:reels/view/homepage.dart';
import 'package:reels/view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends GetWidget<AuthController> {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Obx(() {
        if (controller.isAuthenticated) {
          return MainScreen();
        } else {
          return LoginScreen();
        }
      })
    );
  }
}
