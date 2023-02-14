import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class MyLoadingIndicator extends StatefulWidget {
  const MyLoadingIndicator({super.key});

  @override
  State<MyLoadingIndicator> createState() => _MyLoadingIndicatorState();
}

class _MyLoadingIndicatorState extends State<MyLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    animation = Tween<double>(begin: 0, end: 100)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      })
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          LoadingIndicator(
            size: animation.value,
            borderWidth: animation.value / 20,
            color: Colors.amber,
          ),
          const LoadingIndicator(
            size: 100,
            borderWidth: 5,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class MyProfileButton extends StatelessWidget {
  const MyProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => Future.delayed(
        const Duration(milliseconds: 200),
        () => Navigator.push(
          context,
          MaterialPageRoute<ProfileScreen>(
            builder: (context) => ProfileScreen(
              appBar: AppBar(
                title: const Text('User Profile'),
                centerTitle: true,
              ),
              actions: [
                SignedOutAction((context) {
                  Navigator.popUntil(context,
                      (route) => route.isFirst); //Back to the first screen
                })
              ],
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Image.asset('assets/GIFs/taxi.gif'),
                ),
              ],
            ),
          ),
        ),
      ),
      child: IconButton(
        icon: CircleAvatar(
          foregroundImage:
              NetworkImage(FirebaseAuth.instance.currentUser!.photoURL ?? ''),
          backgroundImage: const AssetImage('assets/GIFs/unknown.gif'),
        ),
        onPressed: null,
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    User currentUser = FirebaseAuth.instance.currentUser!;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: SafeArea(
            child: Column(
              children: [
                InkResponse(
                  onTap: () {
                    Future.delayed(
                      const Duration(milliseconds: 200),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<ProfileScreen>(
                          builder: (context) => ProfileScreen(
                            appBar: AppBar(
                              title: const Text('User Profile'),
                              centerTitle: true,
                            ),
                            actions: [
                              SignedOutAction((context) {
                                Navigator.popUntil(
                                    context,
                                    (route) => route
                                        .isFirst); //Back to the first screen
                              })
                            ],
                            children: [
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: Image.asset('assets/GIFs/taxi.gif'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.redAccent.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    otherAccountsPictures: const [
                      CircleAvatar(child: Icon(Icons.settings))
                    ],
                    accountName: Text(
                      currentUser.displayName ?? 'Anonymous',
                      style: const TextStyle(color: Colors.white),
                    ),
                    accountEmail: Text(
                      currentUser.email ?? 'Anonymous',
                      style: const TextStyle(color: Colors.white),
                    ),
                    currentAccountPicture: CircleAvatar(
                      foregroundImage: NetworkImage(currentUser.photoURL ?? ''),
                      backgroundImage:
                          const AssetImage('assets/GIFs/unknown.gif'),
                    ),
                  ),
                ),
                // const Divider(),
                const ListTile(
                  title: Text(
                    'About Us',
                  ),
                  leading: Icon(Icons.supervised_user_circle_rounded),
                ),
                const ListTile(
                  title: Text(
                    'How to Use',
                  ),
                  leading: Icon(Icons.question_mark_rounded),
                ),
                const Divider(),
                const ListTile(
                  title: Text(
                    'Privacy',
                  ),
                  leading: Icon(Icons.privacy_tip),
                ),
                const ListTile(
                  title: Text(
                    'Terms & Conditions',
                  ),
                  leading: Icon(Icons.text_snippet),
                ),
                const Divider(),
                const SignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
