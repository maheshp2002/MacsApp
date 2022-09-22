import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

// Creating Page
class VideoCall extends StatefulWidget {
  final username;
  VideoCall({Key? key,this.username}) : super(key: key);
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  //final emailText = TextEditingController(text: "Type down your email");
  // final iosAppBarRGBAColor =
  //     TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = true;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            leading: IconButton(
            icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white24, // Change Custom Drawer Icon Color
                  ),
            onPressed: () => Navigator.of(context).pop(),
            ),
            title:  Text(
              "Start video call",
              style: TextStyle(
                color: Colors.white60,fontFamily: 'BrandonBI',
                fontSize: 18,
              ),
            ),
            elevation: 5.0,
            centerTitle: true,
      ), 
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: kIsWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.30,
                      child: meetConfig(),
                    ),
                    Container(
                        width: width * 0.60,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              color: Colors.white54,
                              child: SizedBox(
                                width: width * 0.60 * 0.70,
                                height: width * 0.60 * 0.70,
                                child: JitsiMeetConferencing(
                                  extraJS: [
                                    // extraJs setup example
                                    '<script>function echo(){console.log("echo!!!")};</script>',
                                    '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                  ],
                                ),
                              )),
                        ))
                  ],
                )
              : meetConfig(),
        ),
      ),
    );
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          TextField(
            controller: serverText,
            style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16,
            fontFamily: 'BrandonLI'
            ),
            decoration: InputDecoration(
                labelStyle: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'BrandonBI'
                ),
                hintStyle: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'BrandonLI'
                ),
                border: OutlineInputBorder(),
                labelText: "Server URL",
                hintText: "Hint: Leave empty for meet.jitsi.si"),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: roomText,
            style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16,
            fontFamily: 'BrandonLI'
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'BrandonLI'
              ),
              border: OutlineInputBorder(),
              labelText: "Room",
              hintText: "Type down room name",
              labelStyle: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'BrandonBI'
            ),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: subjectText,
            style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16,
            fontFamily: 'BrandonLI'
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'BrandonLI'
              ),
              border: OutlineInputBorder(),
              labelText: "Subject",
              hintText: "Type down meeting subject",
              labelStyle: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'BrandonBI'
            ),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          // TextField(
          //   controller: nameText,
          //   decoration: InputDecoration(
          //     border: OutlineInputBorder(),
          //     labelText: "Display Name",
          //   ),
          // ),
          SizedBox(
            height: 14.0,
          ),
          // TextField(
          //   controller: emailText,
          //   decoration: InputDecoration(
          //     border: OutlineInputBorder(),
          //     labelText: "Email",
          //   ),
          // ),
          SizedBox(
            height: 14.0,
          ),
          // TextField(
          //   controller: iosAppBarRGBAColor,
          //   decoration: InputDecoration(
          //       border: OutlineInputBorder(),
          //       labelText: "AppBar Color(IOS only)",
          //       hintText: "Hint: This HAS to be in HEX RGBA format"),
          // ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            activeColor: Colors.blueGrey,
            // activeColor: Theme.of(context).scaffoldBackgroundColor,
            // checkColor: Theme.of(context).hintColor,
            title: Text("Audio Only", style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),
            value: isAudioOnly,
            onChanged: _onAudioOnlyChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            activeColor: Colors.blueGrey,
            // activeColor: Theme.of(context).scaffoldBackgroundColor,
            // checkColor: Theme.of(context).hintColor,
            title: Text("Audio Muted", style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),
            value: isAudioMuted,
            onChanged: _onAudioMutedChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            activeColor: Colors.blueGrey,
            //checkColor: Theme.of(context).hintColor,
            title: Text("Video Muted", style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),
            value: isVideoMuted,
            onChanged: _onVideoMutedChanged,
          ),
          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 64.0,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
                if (roomText.text.trim().isEmpty) 
                {

                  Fluttertoast.showToast(  
                  msg: 'No room name..! Please enter a room name..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                } else if (subjectText.text.trim().isEmpty){

                  Fluttertoast.showToast(  
                  msg: 'No subject..! Please enter a subject..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                } else if (roomText.text.trim().length < 3 ) 
                { 
                  
                  Fluttertoast.showToast(  
                  msg: 'Room name should contain atleast 3 character..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                } else {

                  _joinMeeting();

                }
                
              },
              child: Text(
                "Join video call",
                style: TextStyle(fontFamily: 'BrandonBI', color: Colors.white,)
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => Colors.blueGrey)),
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool? value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool? value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomText.text)
      ..serverURL = serverUrl
      ..subject = subjectText.text
      ..userDisplayName = widget.username
      ..userEmail = user!.email!
      //..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": widget.username}
      };

    debugPrint("JitsiMeetingOptions: $options");
    try{
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
    } catch (e) {
      Fluttertoast.showToast(  
      msg: 'Error occured..!\nEither server url is incorrect, or any other issue..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 248, 17, 0),  
      textColor: Colors.white); 

      Future.delayed(const Duration(seconds: 3), () async{
      await Fluttertoast.showToast(  
      msg: 'Try again by leaving server url field as empty..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 248, 17, 0),  
      textColor: Colors.white); 
       });
    }
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {

    Fluttertoast.showToast(  
    msg: '$error',  
    toastLength: Toast.LENGTH_LONG,  
    gravity: ToastGravity.BOTTOM,  
    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
    textColor: Colors.white); 

    debugPrint("_onError broadcasted: $error");
    
  }
}