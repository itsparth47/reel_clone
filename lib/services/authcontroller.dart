import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  Rx<User?> firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
    });
  }

  bool get isAuthenticated => firebaseUser.value != null;
}