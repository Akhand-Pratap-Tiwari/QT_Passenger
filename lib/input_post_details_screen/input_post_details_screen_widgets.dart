import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final int? maxLength;
  final TextEditingController textController;
  final String labelText;
  final Widget iconWidget;

  const MyTextField(
      {super.key,
      this.maxLength,
      required this.textController,
      required this.labelText,
      required this.iconWidget});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: widget.maxLength,
      controller: widget.textController,
      decoration:
          InputDecoration(labelText: widget.labelText, icon: widget.iconWidget),
    );
  }
}

class MyBgContainer extends StatefulWidget {
  final Brightness platformBrightness;

  const MyBgContainer({super.key, required this.platformBrightness});

  @override
  State<MyBgContainer> createState() => _MyBgContainerState();
}

class _MyBgContainerState extends State<MyBgContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        // backgroundBlendMode: BlendMode.color,
        color: widget.platformBrightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
      ),
    );
  }
}

class AddPostButton extends StatelessWidget {
  final String? destination;
  final String? passengerId;
  final bool? shared;
  final String? time;
  final FirebaseFirestore database;

  const AddPostButton(
      {super.key,
      required this.destination,
      required this.passengerId,
      required this.shared,
      required this.time,
      required this.database});

  @override
  Widget build(BuildContext context) {
    void showAlert(
        {contentText = 'Input a valid value', contentColor = Colors.red}) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  '$contentText',
                  style: TextStyle(color: contentColor, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      );
    }

    CollectionReference post = database.collection('post');
    CollectionReference passengers = database.collection('passengers');
    User currentUser = FirebaseAuth.instance.currentUser!;

    Future<void> addPost() {
      return post
          .doc(currentUser.uid)
          .set({
            'passengerId': passengerId,
            'destination': destination,
            'shared': shared,
            'time': time,
            'photoURL': currentUser.photoURL,
          })
          .onError((error, _) =>
              {showAlert(contentText: 'Failed to Add Post: $error')})
          .then((_) {
            passengers
                .doc(currentUser.uid)
                .set({
                  'passengerId': passengerId,
                  'riding': false,
                })
                .onError((error, _) =>
                    {showAlert(contentText: 'Failed to Add Post: $error')})
                .then((_) => database
                        .collection('bids')
                        .where('passengerId', isEqualTo: passengerId)
                        .get()
                        .then((value) {
                      for (DocumentSnapshot bid in value.docs) {
                        bid.reference.delete();
                      }
                    }))
                .then((_) {
                  showAlert(
                      contentText: 'Post Added', contentColor: Colors.blue);
                });
          });
    }

    return InkResponse(
      onTap: () => Future.delayed(
        const Duration(milliseconds: 200),
        () {
          time == null || time == '' || destination == null || destination == ''
              ? showAlert()
              : addPost().then(
                  (value) => Navigator.of(context).pop(),
                );
        },
      ),
      child: const FloatingActionButton.extended(
        heroTag: 'butt',
        icon: Icon(Icons.add_circle_outline_rounded),
        label: Text('Add Post'),
        onPressed: null,
      ),
    );
  }
}
