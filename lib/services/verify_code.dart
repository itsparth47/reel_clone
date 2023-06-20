import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reels/view/homepage.dart';
import 'package:reels/utils/round_button.dart';
import 'package:reels/utils/utils.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verificationId;
  const VerifyCodeScreen({Key? key,
    required this.verificationId}) : super(key: key);

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  bool loading = false;
  final auth = FirebaseAuth.instance;
  final verifyCode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.text,
              controller: verifyCode,
              decoration: InputDecoration(
                  hintText: '6 Digit-Code'
              ),
            ),
            SizedBox(height: 30,),
            RoundButton(title: 'Login', loading: loading, onTap: ()async{
              setState(() {
                loading = true;
              });
              final credential = PhoneAuthProvider.credential(
                  verificationId: widget.verificationId,
                  smsCode: verifyCode.text.toString()
              );
              try {
                await auth.signInWithCredential(credential);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
              }catch(e){
                setState(() {
                  loading = false;
                });
                Utils().toastMessage(e.toString());
              }
            }),
          ],
        ),
      ),
    );
  }
}