import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:attorney/auth/ClientProfile.dart';
import 'package:attorney/auth/splash.dart';
import 'package:attorney/client/attestedServices/attestedCopy.dart';
import 'package:attorney/client/filingApplicationPendingCaseServices/filingPendingCase.dart';
import 'package:attorney/client/filingCaseServices/filingCase.dart';
import 'package:attorney/client/hearingServices/hearingCase.dart';
import 'package:attorney/client/interimOrderServices/interimOrderCase.dart';
import 'package:attorney/client/main/AboutUs.dart';
import 'package:attorney/client/main/pdf_view_screen.dart';
import 'package:attorney/client/requestedCases/RequestCasesMain.dart';
import 'package:attorney/client/summonServices/NewPaperAdCase.dart';
import 'package:attorney/client/summonServices/SummonCase.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'package:social_share/social_share.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientHomeScreen extends StatefulWidget {
  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(this.context, updateState, showProgressDialog);
    }

    return Scaffold(
      key: helper!.scaffoldKey,
      drawer: helper!.drawerContainer(),
      backgroundColor: Utility.whiteColor,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading, // Bind loading state to ModalProgressHUD
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                helper!.statusBarContainer(),
                helper!.actionBarContainer(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    children: [helper!.bodyContainer()],
                  ),
                ),
                helper!.safeBarContainer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void initState() {
    super.initState();
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  void showProgressDialog(bool value) {
    if (mounted) {
      setState(() {
        _isLoading =
            value; // Update loading state to show or hide the modal progress HUD
      });
    }
  }
}

class Helper {
  BuildContext context;
  late Function updateState, showProgressDialog;
  TextEditingController phoneNumberController = TextEditingController();
  FocusNode phoneNumberFocusNode = FocusNode();
  SharedPreferences? preferences;
  int pendingCaseCount = 100;
  int inProgressCaseCount = 0;
  int completedCaseCount = 0;
  int paymentMethodCount = 0;
  // FirebaseAuth? auth;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late FirebaseMessaging? _firebaseMessaging;

  Helper(this.context, this.updateState, this.showProgressDialog) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
    _firebaseMessaging = FirebaseMessaging.instance;
    Timer(Duration(seconds: 1), () {
      if (Utility.modelUser!.fcm_token == '') {
        firebaseCloudMessaging_Listeners();
      }
    });
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // local notification
      print(message);
    });
  }

  Widget statusBarContainer() {
    return Container(
        height: MediaQuery.of(context).padding.top,
        width: MediaQuery.of(context).size.width,
        color: Utility.textBlackColor);
  }

  Widget safeBarContainer() {
    return Container(
      height: MediaQuery.of(context).padding.bottom,
      width: MediaQuery.of(context).size.width,
      color: Utility.textBlackColor,
    );
  }

  Widget actionBarContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Utility.textBlackColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )),
      child: Row(
        children: <Widget>[
          Container(alignment: Alignment.centerLeft, width: 40, child: null),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 45,
              child: Text(
                Utility.app_name.toUpperCase(),
                style: TextStyle(
                    color: Utility.whiteColor,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'bold'),
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              width: 40,
              child: InkWell(
                onTap: () {
                  scaffoldKey.currentState!.openDrawer();
                },
                child: Container(
                    alignment: Alignment.centerLeft,
                    width: 45,
                    child: Icon(
                      Icons.menu,
                      size: 35,
                      color: Utility.whiteColor,
                    )),
              )),
        ],
      ),
    );
  }

  Widget bodyContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RequestedCasesMainScreen(1))).then((value) {
                    apiUpdateCounter();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: 100,
                  width: MediaQuery.of(context).size.width / 1.9 - 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFF95757),
                    borderRadius: BorderRadius.circular(15),
                    // boxShadow: [new BoxShadow(
                    //     color: Utility.shadowColor,
                    //     blurRadius: 10,
                    //     offset: Offset(0, 4),
                    //   spreadRadius: 0.5
                    // )],
                  ),
                  child: Row(
                    children: [
                      Container(
                        // height: 30,
                        width: 100,
                        child: Text(
                          'Pending \Payment',
                          style: TextStyle(
                            color: Utility.textBlackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'medium',
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          height: 30,
                          alignment: Alignment.center,
                          child: Text(
                            Utility.modelUser!.pendingCaseCounts.toString(),
                            style: TextStyle(
                                color: Utility.textBlackColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'medium'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RequestedCasesMainScreen(2))).then((value) {
                    apiUpdateCounter();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: 100,
                  width: MediaQuery.of(context).size.width / 1.9 - 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE560),
                    borderRadius: BorderRadius.circular(15),
                    // boxShadow: [new BoxShadow(
                    //     color: Utility.shadowColor,
                    //     blurRadius: 10,
                    //     offset: Offset(0, 4),
                    //     spreadRadius: 0.5
                    // )],
                  ),
                  child: Row(
                    children: [
                      Container(
                        // height: 30,
                        width: 110,
                        child: Text(
                          'In-progress',
                          style: TextStyle(
                            color: Utility.textBlackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'medium',
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          height: 30,
                          alignment: Alignment.center,
                          child: Text(
                            Utility.modelUser!.inProgressCaseCounts.toString(),
                            style: TextStyle(
                                color: Utility.textBlackColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'medium'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RequestedCasesMainScreen(3))).then((value) {
                    apiUpdateCounter();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: 100,
                  width: MediaQuery.of(context).size.width / 1.9 - 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF92F371),
                    borderRadius: BorderRadius.circular(15),
                    // boxShadow: [new BoxShadow(
                    //     color: Utility.shadowColor,
                    //     blurRadius: 10,
                    //     offset: Offset(0, 4),
                    //   spreadRadius: 0.5
                    // )],
                  ),
                  child: Row(
                    children: [
                      Container(
                        // height: 30,
                        width: 110,
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: Utility.textBlackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'medium',
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          height: 30,
                          alignment: Alignment.center,
                          child: Text(
                            Utility.modelUser!.completedCaseCounts.toString(),
                            style: TextStyle(
                                color: Utility.textBlackColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'medium'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  print('pdf');
                  //assets/pdf/how-it-works.pdf
                  // SfPdfViewer.network('https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PdfViewer()));
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: 100,
                  width: MediaQuery.of(context).size.width / 1.9 - 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFA9F6F6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'About of App',
                    style: TextStyle(
                      color: Utility.textBlackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'medium',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Text(
              'Please Select any of the Service to get your work done fast through your Attorney.',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'medium'),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientAttestedScreen()))
                  .then((value) {
                apiUpdateCounter();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Attested Copy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.attested_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              print('Hearing case');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HearingCaseScreen())).then((value) {
                apiUpdateCounter();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Next Date of Hearing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.next_date_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InterimOrderCaseScreen()))
                  .then((value) {
                apiUpdateCounter();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 65,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Interim Order/Last\nOrder of Court',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.interim_order_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FilingCaseScreen())).then((value) {
                apiUpdateCounter();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'File your Case',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.case_filing_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FilingPendingCaseScreen()))
                  .then((value) {
                apiUpdateCounter();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 65,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Filing any Application\nin Pending Case',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.application_filing_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SummonScreen()))
                  .then((value) {
                apiUpdateCounter();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Summons/Notices',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.summon_notices_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewsPaperAdScreen())).then((value) {
                apiUpdateCounter();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'News Paper Ad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.newspaper_ad_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }

  Widget drawerContainer() {
    return Drawer(
      child: Container(
        color: Color(0xFFFFFCF2),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 25,
                  left: 25,
                  right: 25),
              height: MediaQuery.of(context).size.height / 3.2,
              width: MediaQuery.of(context).size.width,
              color: Utility.textBlackColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey, shape: BoxShape.circle),
                    height: 55,
                    width: 55,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Utility.textWhiteColor,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      Utility.modelUser!.name,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'bold',
                          fontWeight: FontWeight.bold,
                          color: Utility.textWhiteColor),
                    ),
                  ),
                  // Container(
                  //   child: Text(
                  //     'class name',
                  //     style: TextStyle(
                  //         fontSize: 20,
                  //         fontFamily: 'bold',
                  //         fontWeight: FontWeight.bold,
                  //         color: Utility.textWhiteColor
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientProfileScreen()));
                      updateState();
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  height: 25,
                                  child: Icon(
                                    Icons.person,
                                    size: 28,
                                    color: Utility.textBlackColor,
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                child: Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'semibold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.of(context).pop();
                      // SocialShare.shareWhatsapp("Hello World");
                      openwhatsapp();
                      updateState();
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  height: 25,
                                  child: Icon(
                                    Icons.chat,
                                    size: 28,
                                    color: Utility.textBlackColor,
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                child: Text(
                                  'Chat Support',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'semibold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      shareApp();
                      updateState();
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  height: 25,
                                  child: Icon(
                                    Icons.mobile_screen_share_sharp,
                                    size: 28,
                                    color: Utility.textBlackColor,
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                child: Text(
                                  'Invite',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'semibold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutUsScreen()));
                      updateState();
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  height: 25,
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 28,
                                    color: Utility.textBlackColor,
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                child: Text(
                                  'Services of App',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'semibold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      logout();
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                child: Icon(
                                  Icons.logout,
                                  color: Utility.textBlackColor,
                                  size: 28,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'semibold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Utility.toastBackgroundColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void logout() {
    preferences!.setBool('isLoggedIn', false).then((isEmailSet) {
      preferences!.setString('mobile', '').then((isEmailSet) {
        preferences!.setString('password', '').then((isPasswordSet) {
          Utility.userLoggedIn = false;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Splash()),
              (route) => false);
          updateState();
        });
      });
    });
  }

  openwhatsapp() async {
    var contact = "+923063377772";
    var androidUrl =
        "whatsapp://send?phone=$contact&text=Welcome to Attorney Official Support";
    var iosUrl =
        "https://wa.me/$contact?text=${Uri.parse('Welcome to Attorney Official Support')}";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      SnackBar(content: new Text("whatsapp no installed"));
    }

    Navigator.of(context).pop();
  }

  shareApp() async {
    if (Platform.isIOS) {
      Share.share(
          'Download & Install Attorney Official https://play.google.com/store/apps/details?id=com.attorneyOfficial.app');
    } else {
      Share.share(
          'Download & Install Attorney Official https://play.google.com/store/apps/details?id=com.attorneyOfficial.app');
    }
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging!.getToken().then((token) {
      print(token);
      apiUpdateGuardFcmToken(token);
    });
  }

  void apiUpdateGuardFcmToken(fcm_token) {
    Map<String, String> params = Map();
    Map<String, String> headers = Map();

    headers['Authorization'] = Utility.modelUser!.token;

    params['fcm_token'] = fcm_token;

    http
        .post(Uri.parse(UPDATE_FCM_TOKEN_URL), body: params, headers: headers)
        .then((response) async {
      showProgressDialog(false);
      Utility.modelUser!.fcm_token = fcm_token;
    });
  }

  void iOS_Permission() {
    _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void apiUpdateCounter() {
    showProgressDialog(true);
    FocusManager.instance.primaryFocus?.unfocus();
    // print('in request case');
    Map<String, String> headers = Map();
    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';

    // print(GET_ALL_CASE_URL + '/' + type);
    http
        .get(Uri.parse(UPDATE_COUNTER_URL), headers: headers)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        if (mappingResponse['data'] != null) {
          Utility.modelUser!.pendingCaseCounts =
              mappingResponse['data']['pendingCaseCounts'];
          Utility.modelUser!.inProgressCaseCounts =
              mappingResponse['data']['inProgressCaseCounts'];
          Utility.modelUser!.completedCaseCounts =
              mappingResponse['data']['completedCaseCounts'];
          updateState();
        } else {
          showToast(mappingResponse['message']);
        }
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }
}
