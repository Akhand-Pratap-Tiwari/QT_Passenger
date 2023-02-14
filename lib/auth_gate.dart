import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:quick_taxi/bids_screen/bids_screen.dart';
import 'package:quick_taxi/final_screen/final_screen.dart';
import 'global_common_widgets.dart';
import 'keys/keys.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: const [
              EmailProviderConfiguration(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/GIFs/taxi.gif'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: action == AuthAction.signIn
                    ? const Text('Please Sign In')
                    : const Text('Please Sign Up'),
              );
            },
            footerBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white12
                          : Colors.black87,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Column(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Center(
                          child: Text(
                            'or',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      GoogleSignInButton(
                          clientId: googleProviderConfigurationClientID),
                      PhoneVerificationButton(label: "Sign In With Phone"),
                    ],
                  ),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/GIFs/taxi.gif'),
                ),
              );
            },
          );
        }
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('passengers')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong !');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MyLoadingIndicator();
              }
              if (!snapshot.hasData ||
                  !snapshot.data!.exists ||
                  snapshot.data!.data()!['riding'] == false) {
                return const BidsScreen();
              }
              return const FinalScreen();
            });
      },
    );
  }
}
