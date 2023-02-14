import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_taxi/global_common_widgets.dart';
import 'package:quick_taxi/input_post_details_screen/input_post_details_screen_widgets.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class InputPostDetailsScreen extends StatefulWidget {
  const InputPostDetailsScreen({super.key});

  @override
  State<InputPostDetailsScreen> createState() => _InputPostDetailsScreenState();
}

class _InputPostDetailsScreenState extends State<InputPostDetailsScreen> {
  var destinationText = TextEditingController();
  var sharedText = TextEditingController();
  var timeText = TextEditingController();
  bool? grpVal = true;

  @override
  Widget build(BuildContext context) {
    var platformBrightness = MediaQuery.of(context).platformBrightness;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: platformBrightness == Brightness.dark
            ? null
            : Colors.amber,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          actions: const [MyProfileButton(),],
          backgroundColor:
              platformBrightness == Brightness.dark ? Colors.black : null,
          title: const Text('ENTER DETAILS'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            child: Center(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  MyBgContainer(platformBrightness: platformBrightness),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 30),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyTextField(
                            textController: destinationText,
                            labelText: 'Enter Destination',
                            iconWidget: const Icon(Icons.place, size: 30),
                            maxLength: 25,
                          ),
                          TextField(
                            readOnly: true,
                            onTap: () async {
                              showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now())
                                  .then((value) => setState(() {
                                        timeText.text = (value == null)
                                            ? TimeOfDay.now().format(context)
                                            : value.format(context);
                                      }));
                            },
                            controller: timeText,
                            decoration: const InputDecoration(
                              labelText: 'Choose Time',
                              icon: Icon(Icons.access_time_rounded, size: 30),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                child: RadioListTile<bool>(
                                  title: const Text('Shared'),
                                  value: true,
                                  groupValue: grpVal,
                                  onChanged: (value) {
                                    setState(() {
                                      grpVal = value;
                                    });
                                  },
                                ),
                              ),
                              Flexible(
                                child: RadioListTile<bool>(
                                  title: const Text('Single'),
                                  value: false,
                                  groupValue: grpVal,
                                  onChanged: (value) {
                                    setState(() {
                                      grpVal = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          AddPostButton(
                            destination: destinationText.text.trim(),
                            passengerId: FirebaseAuth.instance.currentUser!.uid, //can't be null at this phase as user has signed in
                            shared: grpVal,
                            time: timeText.text.trim(),
                            database: db,
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
