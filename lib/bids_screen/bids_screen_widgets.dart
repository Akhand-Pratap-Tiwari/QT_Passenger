import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:quick_taxi/bids_screen/bids_screen.dart';

import '../confirmation_page/confirmation_page.dart';

class MyListTile extends StatefulWidget {
  final BidDetails bidDetails;

  const MyListTile({super.key, required this.bidDetails});

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  var color = Colors.pink;

  double rating = 0.0;
  int n = 0;
  void _confirmaPageRoute({required bidDetails}) {
    Navigator.push(
      context,
      MaterialPageRoute<ConfirmationPage>(
        builder: (context) => ConfirmationPage(bidDetails: bidDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.amber.shade800, Colors.amber],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            onTap: () => _confirmaPageRoute(bidDetails: widget.bidDetails),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.bidDetails.driverPhone),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('drivers')
                      .doc(widget.bidDetails.driverId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Something went wrong !'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return const SizedBox(
                        width: 105,
                        height: 5,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white,
                          color: Colors.pink,
                        ),
                      );
                    }

                    rating = snapshot.data != null
                        ? snapshot.data!['rating'].toDouble()
                        : 0.0;
                    widget.bidDetails.rating = rating;
                    n = snapshot.data != null ? snapshot.data!['n'].toInt() : 0;
                    widget.bidDetails.n = n;
                    return Row(
                      children: [
                        RatingBar(
                          itemSize: 15,
                          allowHalfRating: true,
                          initialRating: rating,
                          ignoreGestures: true,
                          ratingWidget: RatingWidget(
                              empty:
                                  Icon(Icons.star_border_rounded, color: color),
                              full: Icon(Icons.star_rate_rounded, color: color),
                              half:
                                  Icon(Icons.star_half_rounded, color: color)),
                          onRatingUpdate: (value) {},
                        ),
                        Text(' • $n')
                      ],
                    );
                  },
                ),
              ],
            ),
            leading: Hero(
              tag: widget.bidDetails.driverId +
                  widget.bidDetails.price.toString(),
              child: CircleAvatar(
                // radius: 20,
                foregroundImage: NetworkImage(widget.bidDetails.driverPhoto),
                onForegroundImageError: (exception, stackTrace) {},
                backgroundImage: const AssetImage('assets/GIFs/unknown.gif'),
              ),
            ),
            textColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 125,
                  child: Text(
                    widget.bidDetails.driverName,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.red,
                  ),
                  child: SizedBox(
                    width: 80,
                    child: Center(
                      child: Text(
                        '₹${widget.bidDetails.price}',
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostView extends StatefulWidget {
  final PostDetails? postDetails;


  /// *Type is _BidsScreenState. I know this is a bad
  ///  idea but hi time is running out and I have to show the demo
  final bidScreenState;

  const PostView(
      {super.key, required this.postDetails, required this.bidScreenState});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  FirebaseFirestore database = FirebaseFirestore.instance;
  var currentUser = FirebaseAuth.instance.currentUser!;
  var passengerId = FirebaseAuth.instance.currentUser!.uid;
  FutureOr _deleteMyPost() {
    database.collection('post').doc(passengerId).delete().then((_) => database
            .collection('bids')
            .where('passengerId', isEqualTo: passengerId)
            .get()
            .then((value) {
          for (DocumentSnapshot bid in value.docs) {
            bid.reference.delete();
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    Color color = MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return widget.postDetails == null
        ? const Text('Null Post')
        : Center(
            child: ListTile(
              tileColor: Colors.transparent,
              trailing: IconButton(
                onPressed: _deleteMyPost,
                icon: const CircleAvatar(
                    foregroundColor: Colors.red,
                    child: Icon(Icons.delete, size: 30)),
              ),
              leading: PopupMenuButton(
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    onTap: () {
                      widget.bidScreenState.setState(() {
                        widget.bidScreenState.userStream = FirebaseFirestore
                            .instance
                            .collection('bids')
                            .where('passengerId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .orderBy('price')
                            .snapshots();
                      });
                    },
                    child: TextButton.icon(
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(color)),
                      onPressed: null,
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: const Text('Sort By Price : Low to High'),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      widget.bidScreenState.setState(() {
                        widget.bidScreenState.userStream = FirebaseFirestore
                            .instance
                            .collection('bids')
                            .where('passengerId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .orderBy('price', descending: true)
                            .snapshots();
                      });
                    },
                    child: TextButton.icon(
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(color)),
                      onPressed: null,
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: const Text('Sort By Price : High to Low'),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      widget.bidScreenState.setState(() {
                        widget.bidScreenState.userStream = FirebaseFirestore
                            .instance
                            .collection('bids')
                            .where('passengerId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .snapshots();
                      });
                    },
                    child: TextButton.icon(
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(color)),
                      onPressed: null,
                      icon: const Icon(Icons.access_time_rounded),
                      label: const Text('Sort By Recent'),
                    ),
                  ),
                ],
                child: const CircleAvatar(
                    child: Icon(Icons.sort_rounded, size: 30)),
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 71),
                    child: Text(
                      widget.postDetails!.destination,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    ' • ${widget.postDetails!.time} | ${widget.postDetails!.shared ? 'Shared' : 'Single'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 14),
                  )
                ],
              ),
            ),
          );
  }
}

class ScrollCollapseFAB extends StatefulWidget {
  final ScrollController listViewController;

  const ScrollCollapseFAB({super.key, required this.listViewController});

  @override
  State<ScrollCollapseFAB> createState() => _ScrollCollapseFABState();
}

class StateRecord {
  Widget widget;
  double width;

  StateRecord({required this.widget, required this.width});
}

StateRecord stateRec = StateRecord(
    widget: const Text(
      '  New / Update',
      style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    width: 211);

class _ScrollCollapseFABState extends State<ScrollCollapseFAB> {
  @override
  void initState() {
    widget.listViewController.addListener(() {
      if (widget.listViewController.position.pixels <= 100 && mounted) {
        setState(() {
          stateRec.width = 211;
        });
      } else {
        if (mounted) {
          setState(() {
            stateRec.width = 80;
            stateRec.widget = Container();
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      clipBehavior: Clip.hardEdge,
      curve: Curves.easeInOutBack,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      duration: const Duration(milliseconds: 500),
      onEnd: () {
        if (stateRec.width == 211) {
          setState(() {
            stateRec.widget = const Text(
              '  New / Update',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            );
          });
        }
      },
      height: 60,
      width: stateRec.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.deepOrange.shade700),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.post_add_rounded, color: Colors.white),
          stateRec.widget,
        ],
      ),
    );
  }
}
