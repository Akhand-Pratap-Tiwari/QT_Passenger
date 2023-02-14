import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:quick_taxi/bids_screen/bids_screen.dart';
import 'confirmation_page_widgets.dart';

class ConfirmationPage extends StatefulWidget {
  final BidDetails bidDetails;

  const ConfirmationPage({super.key, required this.bidDetails});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  FirebaseFirestore database = FirebaseFirestore.instance;
  bool fetchingCompleted = false;
  String? dlNo, taxiNo;

  @override
  Widget build(BuildContext context) {
    if (!fetchingCompleted) {
      database
          .collection('drivers')
          .doc(widget.bidDetails.driverId)
          .get()
          .then((value) {
        dlNo = value.data()!['DLNo'];
        taxiNo = value.data()!['TaxiNo'];
      }).then(
        (_) => setState(() {
          fetchingCompleted = true;
        }),
      );
    }
    var color = Colors.pink;
    bool driverPhoneAvailable =
        widget.bidDetails.driverPhone == 'Ph Not Available' ? false : true;
    String shared = widget.bidDetails.shared ? 'Yes' : 'No';
    return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              ///List Tile Below
              Material(
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
                    textColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    leading: Hero(
                      tag: widget.bidDetails.driverId +
                          widget.bidDetails.price.toString(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            // radius: 25,
                            foregroundImage:
                                NetworkImage(widget.bidDetails.driverPhoto),
                            onForegroundImageError: (exception, stackTrace) {},
                            backgroundImage:
                                const AssetImage('assets/GIFs/unknown.gif'),
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RatingBar(
                              itemSize: 15,
                              initialRating: widget.bidDetails.rating ?? 0,
                              allowHalfRating: true,
                              ignoreGestures: true,
                              ratingWidget: RatingWidget(
                                  empty: Icon(Icons.star_border_rounded,
                                      color: color),
                                  full: Icon(Icons.star_rate_rounded,
                                      color: color),
                                  half: Icon(Icons.star_half_rounded,
                                      color: color)),
                              onRatingUpdate: (value) {},
                            ),
                            Text(' • ${widget.bidDetails.n}')
                          ],
                        ),
                        Text('TAXI No: ${taxiNo ?? 'Loading...'}'),
                        Text('DL: ${dlNo ?? 'Loading...'}'),
                      ],
                    ),
                    title: Text(widget.bidDetails.driverName),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          enableFeedback: true,
                          onPressed: () {
                            Clipboard.setData(
                                     ClipboardData(text: widget.bidDetails.driverPhone.toString()))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Phone Number Copied !')));
                            });
                          },
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.circle_sharp,
                                size: 40,
                                color: Colors.white,
                              ),
                              Icon(
                                driverPhoneAvailable
                                    ? Icons.copy
                                    : Icons.phone_disabled,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),

              ///Container with Bid details
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, Colors.yellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            MyText(text: 'Destination : '),
                            MyText(text: 'Shared : '),
                            MyText(text: 'Time : '),
                            MyText(text: 'Price : '),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(text: widget.bidDetails.destination),
                            MyText(text: shared),
                            MyText(text: widget.bidDetails.time),
                            MyText(
                              text: '₹ ${widget.bidDetails.price}',
                              color: Colors.red.shade700,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),

              ///Pink Button Below
              ConfirmationButton(
                bidDetails: widget.bidDetails,
              ),
            ],
          ),
        ));
  }
}
