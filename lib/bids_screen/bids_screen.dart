import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_taxi/bids_screen/bids_screen_widgets.dart';

import '../global_common_widgets.dart';
import '../input_post_details_screen/input_post_details_screen.dart';

class BidDetails {
  double? rating;
  int? n;
  String destination;
  String driverId;
  String driverName;
  String driverPhoto;
  String driverPhone;
  int price;
  bool shared;
  String time;
  String documentId;
  BidDetails(
      {required this.destination,
      required this.documentId,
      required this.driverId,
      required this.driverName,
      required this.driverPhone,
      required this.driverPhoto,
      required this.price,
      required this.shared,
      required this.time});
}

class PostDetails {
  String time;
  String destination;
  String passengerId;
  bool shared;

  PostDetails(
      {required this.passengerId,
      required this.destination,
      required this.shared,
      required this.time});
}

class BidsScreen extends StatefulWidget {
  const BidsScreen({Key? key}) : super(key: key);
  @override
  State<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends State<BidsScreen> {
  Stream<QuerySnapshot> userStream = FirebaseFirestore.instance
      .collection('bids')
      .where('passengerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  final ScrollController _listViewController = ScrollController();
  Widget widget1 = const MyLoadingIndicator();
  User currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('post')
                .doc(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error Loading !');
              }
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const LinearProgressIndicator(
                  color: Colors.pink,
                  backgroundColor: Colors.amber,
                );
              }
              if (!snapshot.data!.exists) {
                return Container();
              }
              var data = snapshot.data!;
              return PostView(
                bidScreenState: this,
                postDetails: PostDetails(
                  passengerId: data['passengerId'],
                  destination: data['destination'],
                  shared: data['shared'],
                  time: data['time'],
                ),
              );
            },
          ),
        ),
        actions: const [MyProfileButton()],
        centerTitle: true,
        title: const Text('Current Bids'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('post')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong !'));
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const MyLoadingIndicator();
          }
          if (!snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No Posts Yet',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }
          return StreamBuilder<QuerySnapshot>(
            stream: userStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong !'));
              }

              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const MyLoadingIndicator();
              }
              if (snapshot.data!.size == 0) {
                return const Center(
                  child: Text(
                    'No Bids On Your Post Yet',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              return ListView(
                controller: _listViewController,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 110),
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return MyListTile(
                        bidDetails: BidDetails(
                            documentId: document.id,
                            destination: data['destination'],
                            driverId: data['driverId'],
                            driverName: data['driverName'],
                            driverPhone: data['driverPhone'] == null ||
                                    data['driverPhone'] == ''
                                ? 'Ph Not Available'
                                : data['driverPhone'],
                            driverPhoto: data['driverPhoto'] ?? '',
                            price: data['price'],
                            shared: data['shared'] == 'true' ? true : false,
                            time: data['time']),
                      );
                    })
                    .toList()
                    .cast(),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: InkResponse(
        onTap: () => Future.delayed(
          const Duration(milliseconds: 200),
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InputPostDetailsScreen()),
          ),
        ),
        child: Hero(
          tag: 'butt',
          child: Material(
            textStyle: const TextStyle(color: Colors.white),
            elevation: 10,
            borderRadius: BorderRadius.circular(20),
            child: ScrollCollapseFAB(
              listViewController: _listViewController,
            ),
          ),
        ),
      ),
    );
  }
}
