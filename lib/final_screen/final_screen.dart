import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../global_common_widgets.dart';

class ConfirmedDriverDetails {
  String? name, bidDocId, driverId, dlNo, taxiNo, photoUrl;
  int? price;
  ConfirmedDriverDetails({
    this.name,
    this.bidDocId,
    this.driverId,
    this.dlNo,
    this.taxiNo,
    this.photoUrl = '',
    this.price,
  });
}

class FinalScreen extends StatefulWidget {
  const FinalScreen({super.key});

  @override
  State<FinalScreen> createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen> {
  var confirmedDriverDetails = ConfirmedDriverDetails();
  String? driverId, bidDocId;
  int? price;
  String belowTxt =
      'Sit tight ! Your ride is on the way. Press the button when you board the ride.';
  String gifPath = 'assets/GIFs/taxiComing2.gif';
  int count = 5;
  bool fetchingCompleted = false;
  bool pressedForFirstTime = false;
  bool stopLocUpdateAndGifChange = false;

  String txt = 'Boarded';
  List<String> gifList = [
    'assets/GIFs/1.gif',
    'assets/GIFs/3.gif',
    'assets/GIFs/4.gif',
    'assets/GIFs/5.gif',
    'assets/GIFs/6.gif',
    'assets/GIFs/taxiComing.gif',
    'assets/GIFs/unknown.gif',
  ];

  void showAlert() {
    double rating = 3;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('Debug: Entered');
                FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(confirmedDriverDetails.driverId)
                    .get()
                    .then((value) {
                      debugPrint('Debug: Inside First then');
                      double currentRating = value.data()!['rating'].toDouble();
                      double currentN = value.data()!['n'].toDouble();
                      double newRating = (currentN * currentRating + rating) /
                          (currentN + 1.0);
                      return [newRating, currentN];
                    })
                    .then((list) {
                      debugPrint(
                          'Debug: Inside second then ${list[0]}, ${list[1]}');
                      FirebaseFirestore.instance
                          .collection('drivers')
                          .doc(confirmedDriverDetails.driverId)
                          .update({
                        'rating': list[0],
                        'n': list[1] + 1.0,
                      });
                    })
                    .then((_) => FirebaseFirestore.instance
                        .collection('passengers')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .delete())
                    .then((_) => FirebaseFirestore.instance
                        .collection('bids')
                        .doc(confirmedDriverDetails.bidDocId)
                        .delete())
                    .then((value) => Navigator.of(context)
                        .popUntil((route) => route.isFirst));
              }, 
              child: const Text('OK'),
            )
          ],
          title: const Text('Rate Your Experience'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingBar(
                minRating: 1,
                maxRating: 5,
                initialRating: 3,
                allowHalfRating: true,
                ratingWidget: RatingWidget(
                    full: const Icon(Icons.star_rounded),
                    half: const Icon(Icons.star_half_rounded),
                    empty: const Icon(Icons.star_border_rounded)),
                onRatingUpdate: (value) => rating = value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void gifPathUpdater() async {
    while (!stopLocUpdateAndGifChange) {
      await Future.delayed(
        const Duration(seconds: 10),
        () => setState(() {
          if (count <= 6) {
            gifPath = gifList[count];
            count++;
          } else {
            gifPath = gifList[0];
            count = 1;
          }
        }),
      );
    }
  }

  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String?> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  }

  Future<void> sendLocation() async {
    await getGeoLocationPosition()
        .then((position) => getAddressFromLatLong(position).then(
              (address) => FirebaseFirestore.instance
                  .collection('passengers')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'lat': position.latitude,
                'long': position.longitude,
                'address': address,
                'timeStamp': DateTime.now().toLocal().toString()
              }),
            ));
  }

  void locationUpdater() async {
    await sendLocation().then((_) async {
      while (!stopLocUpdateAndGifChange) {
        await Future.delayed(
            const Duration(minutes: 15), //15mins
            () async => sendLocation());
      }
    });
  }

  void locUpdateAndGifChanger() {
    setState(() {
      belowTxt = 'Press the button when you arrive at destination';
      pressedForFirstTime = true;
      txt = 'I have arrived';
    });
    gifPathUpdater();
    locationUpdater();
  }

  @override
  Widget build(BuildContext context) {
    if (!fetchingCompleted) {
      FirebaseFirestore.instance
          .collection('passengers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
            bidDocId = value.data()!['docId'];
            driverId = value.data()!['driverId'];
            price = value.data()!['price'];
          })
          .then((_) => FirebaseFirestore.instance
                  .collection('drivers')
                  .doc(driverId)
                  .get()
                  .then((value2) {
                confirmedDriverDetails.dlNo = value2.data()!['DLNo'];
                confirmedDriverDetails.bidDocId = bidDocId;
                confirmedDriverDetails.driverId = driverId;
                confirmedDriverDetails.price = price;
                confirmedDriverDetails.name = value2.data()!['name'];
                confirmedDriverDetails.photoUrl =
                    value2.data()!['profilePhoto'] ?? '';
                confirmedDriverDetails.taxiNo = value2.data()!['TaxiNo'];
              }))
          .then(
            (_) => setState(() {
              fetchingCompleted = true;
            }),
          );
    }

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(actions: const [MyProfileButton()]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          const AssetImage('assets/GIFs/unknown.gif'),
                      foregroundImage:
                          NetworkImage(confirmedDriverDetails.photoUrl!),
                      onForegroundImageError: (_, __) => {}),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Name : '),
                      Text('DL : '),
                      Text('Taxi : '),
                      Text('Price : '),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(confirmedDriverDetails.name ?? 'Loading...'),
                      Text(confirmedDriverDetails.dlNo ?? 'Loading...'),
                      Text(confirmedDriverDetails.taxiNo ?? 'Loading...'),
                      Text(confirmedDriverDetails.price == null
                          ? 'Loading...'
                          : '₹ ${confirmedDriverDetails.price}'),
                    ],
                  ),
                ],
              ),
              const Divider(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: ClipRRect(
                  key: ValueKey(count),
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    gifPath,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Text(
                belowTxt,
                style: const TextStyle(fontSize: 20),
              ),
              !fetchingCompleted
                  ? const MyLoadingIndicator()
                  : InkResponse(
                      onTap: () =>
                          Future.delayed(const Duration(milliseconds: 200), () {
                        if (!pressedForFirstTime) {
                          locUpdateAndGifChanger();
                        } else {
                          stopLocUpdateAndGifChange = true;
                          showAlert();
                        }
                      }),
                      child: FloatingActionButton.extended(
                        heroTag: 'butt',
                        onPressed: null,
                        label: Text(txt),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
