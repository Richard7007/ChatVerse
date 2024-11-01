import 'package:chat_app/widgets/build_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String isLogged = 'isLogged';
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _retrieveFCMToken();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    bool userExists = await checkIfUserExists(
        user!.uid, user.displayName.toString(), user.photoURL.toString());
    if (!userExists) {
      addToFirestore(
        email: user.email.toString(),
        uid: user.uid,
        name: user.displayName.toString(),
        photoURL: user.photoURL.toString(),
      );
    }
  }

  Future<bool> checkIfUserExists(
      String uid, String name, String photoURL) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addToFirestore({
    required String uid,
    required String email,
    required String name,
    required String photoURL,
    String? docId,
  }) async {
    print(uid);
    print(email);
    print(name);

    DocumentReference docRef = docId != null
        ? FirebaseFirestore.instance.collection('user').doc(docId)
        : FirebaseFirestore.instance.collection('user').doc();

    String documentId = docRef.id;

    await docRef.set({
      'uid': uid,
      'email': email,
      'name': name,
      'docId': documentId,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
    });
    print('Document ID: $documentId');
  }

  void _retrieveFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
          color: Colors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 35,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(
            //     bottom: 80,
            //   ),
            //   child: BuildTextWidget(
            //     text: 'ChatApp',
            //     style: TextStyle(
            //       color: Colors.indigo.shade400,
            //       fontSize: 50,
            //       fontFamily: 'Pattaya',
            //     ),
            //   ),
            // ),
            const BuildTextWidget(
              text: 'Create new Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 37,
                fontFamily: 'Pattaya',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BuildTextWidget(
                  text: 'Already have account?',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Pattaya',
                    fontSize: 19,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: BuildTextWidget(
                    text: 'Login',
                    style: TextStyle(
                      color: Colors.indigo.shade400,
                      fontFamily: 'Pattaya',
                      fontSize: 19,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40.00,
            ),
            SizedBox(
              height: 75,
              width: 340,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 33,
                  right: 35,
                  bottom: 20,
                ),
                child: TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Pattaya',
                  ),
                  //asdfghj
                  textAlign: TextAlign.center,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  decoration: InputDecoration(
                    hintText: 'Enter Mobile Number',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Pattaya',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              width: 275,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.indigo.shade400,
                  ),
                ),
                child: _isLoading
                    ? const SpinKitThreeBounce(
                        color: Colors.white,
                        size: 25,
                      )
                    : const BuildTextWidget(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pattaya',
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    indent: 90,
                    color: Colors.indigo.shade400,
                  ),
                ),
                const BuildTextWidget(
                  text: '  OR  ',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Pattaya',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Divider(
                    endIndent: 90,
                    color: Colors.indigo.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              width: 275,
              child: ElevatedButton(
                onPressed: _isGoogleLoading
                    ? null
                    : () async {
                        setState(() {
                          _isGoogleLoading = true;
                        });
                        await signInWithGoogle();
                        setState(() {
                          _isGoogleLoading = false;
                        });
                        if (context.mounted) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(
                                index: 0,
                                content: '',
                              ),
                            ),
                          );
                        }
                      },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.white,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Colors.indigo.shade400,
                  ),
                ),
                child: _isGoogleLoading
                    ? SpinKitThreeBounce(
                        color: Colors.indigo.shade400,
                        size: 25,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            child: Image.asset(
                              'assets/images/google logo.png',
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          BuildTextWidget(
                            text: 'Sign in with Google',
                            style: TextStyle(
                              color: Colors.indigo.shade400,
                              fontFamily: 'Pattaya',
                            ),
                          ),
                          BuildTextWidget(
                            text: 'Sign in with Google',
                            style: TextStyle(
                              color: Colors.indigo.shade400,
                              fontFamily: 'Pattaya',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ignore_for_file: avoid_print
