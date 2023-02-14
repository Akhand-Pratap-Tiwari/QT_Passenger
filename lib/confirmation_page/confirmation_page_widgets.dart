import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_taxi/bids_screen/bids_screen.dart';

class MyText extends StatelessWidget {
  final Color color;
  final String text;

  const MyText({super.key, required this.text, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
    );
  }
}

class ConfirmationButton extends StatefulWidget {
  final BidDetails bidDetails;

  const ConfirmationButton({super.key, required this.bidDetails});

  @override
  State<ConfirmationButton> createState() => _ConfirmationButtonState();
}

class _ConfirmationButtonState extends State<ConfirmationButton> {
  FirebaseFirestore database = FirebaseFirestore.instance;
  String passengerId = FirebaseAuth.instance.currentUser!.uid;
  _confirmBooking() {
    database
        .collection('bids')
        .doc(widget.bidDetails.documentId)
        .update({'accepted': true}).then((_) {
      database
          .collection('post')
          .doc(passengerId)
          .delete()
          .then((_) {
        database
            .collection('passengers')
            .doc(passengerId)
            .update({
          'riding': true,
          'docId': widget.bidDetails.documentId,
          'driverId': widget.bidDetails.driverId,
          'price':widget.bidDetails.price
        }).then((_) {
          database
          .collection('bids')
          .where('passengerId', isEqualTo: passengerId )
          .get()
          .then((value) {
            for (DocumentSnapshot bid in value.docs) {
              if(bid.id != widget.bidDetails.documentId) bid.reference.delete();
            }
          });
        }).whenComplete(
                () => Navigator.popUntil(context, (route) => route.isFirst));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => Future.delayed(const Duration(milliseconds: 200), () => _confirmBooking()),
      child: const FloatingActionButton.extended(
        heroTag: 'butt',
        elevation: 10,
        backgroundColor: Colors.pink,
        onPressed: null,
        icon: Icon(Icons.check_circle_outline_rounded),
        label: Text('Confirm Booking'),
      ),
    );
  }
}
