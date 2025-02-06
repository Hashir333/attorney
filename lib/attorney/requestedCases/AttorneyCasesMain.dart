import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:attorney/attorney/requestedCases/AttroneyAttestedCopyCaseDetails.dart';
import 'package:attorney/attorney/requestedCases/AttroneyCaseDetails.dart';
import 'package:attorney/attorney/requestedCases/AttroneyNewsPaperCopyCaseDetails.dart';
import 'package:attorney/auth/LawyerProfile.dart';
import 'package:attorney/auth/splash.dart';
import 'package:attorney/models/case.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AttorneyCasesMainScreen extends StatefulWidget {
  @override
  _AttorneyCasesMainScreenState createState() =>
      _AttorneyCasesMainScreenState();
}

class _AttorneyCasesMainScreenState extends State<AttorneyCasesMainScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace the progressHUD with a loading state

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
        inAsyncCall:
            _isLoading, // Pass the loading state to the modal progress HUD
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                helper!.statusBarContainer(),
                helper!.actionBarContainer(),
                helper!.topBarContainer(),
                Expanded(
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(0),
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
  SharedPreferences? preferences;
  late FirebaseMessaging? _firebaseMessaging;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Helper(this.context, this.updateState, this.showProgressDialog) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
    apiGetAllCases('2');
    _firebaseMessaging = FirebaseMessaging.instance;
    Timer(Duration(seconds: 1), () {
      if (Utility.modelUser!.fcm_token == '') {
        firebaseCloudMessaging_Listeners();
      }
    });
  }

  int selectedCaseType = 2;

  List<ModelCase>? caseList = null;

  Widget statusBarContainer() {
    return Container(
      height: MediaQuery.of(context).padding.top,
      width: MediaQuery.of(context).size.width,
      color: Utility.primaryColor,
    );
  }

  Widget safeBarContainer() {
    return Container(
      height: MediaQuery.of(context).padding.bottom,
      width: MediaQuery.of(context).size.width,
      color: Utility.primaryColor,
    );
  }

  Widget actionBarContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      width: MediaQuery.of(context).size.width,
      color: Utility.primaryColor,
      child: Row(
        children: <Widget>[
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
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 45,
              child: Text(
                'Requested Cases'.toUpperCase(),
                style: TextStyle(
                    color: Utility.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              width: 40,
              child: InkWell(
                onTap: () {
                  logout();
                },
                child: Container(
                    alignment: Alignment.centerLeft,
                    width: 40,
                    child: Icon(
                      Icons.logout,
                      color: Utility.whiteColor,
                    )),
              )),
        ],
      ),
    );
  }

  Widget bodyContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [caseListView()],
      ),
    );
  }

  Widget topBarContainer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      height: 65,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              showProgressDialog(true);
              apiGetAllCases('2');
              selectedCaseType = 2;
              caseList = null;
              updateState();
            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              width: MediaQuery.of(context).size.width / 2.1,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCaseType == 2
                      ? Utility.primaryColor
                      : Colors.grey.shade400),
              child: Text(
                'In Progress',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Utility.whiteColor),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showProgressDialog(true);
              apiGetAllCases('3');
              selectedCaseType = 3;
              caseList = null;
              updateState();
            },
            child: Container(
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCaseType == 3
                      ? Utility.primaryColor
                      : Colors.grey.shade400),
              width: MediaQuery.of(context).size.width / 2.1,
              child: Text(
                'Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Utility.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget caseListView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemBuilder: caseListViewContainer,
        itemCount: caseList != null
            ? (caseList!.length > 0 ? caseList!.length : 0)
            : 0,
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget caseListViewContainer(BuildContext context, int index) {
    return InkWell(
        onTap: () {},
        child: Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(15),
            // height: 100,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Request #: ${caseList![index].id}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                caseList![index].title != ''
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            width: MediaQuery.of(context).size.width - 60,
                            child: Text(
                              'Case Title: ${caseList![index].title}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Case Status: ${caseList![index].status}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
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
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      width: MediaQuery.of(context).size.width - 60,
                      child: Text(
                        'Case Type: ${caseList![index].case_type_name}',
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
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
                    Container(
                      child: Text(
                        'Attorney: ${caseList![index].attorneyDetails != null ? caseList![index].attorneyDetails!.name : 'not assigned'}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        if (caseList![index].case_type == '1' ||
                            caseList![index].case_type == '2' ||
                            caseList![index].case_type == '3' ||
                            caseList![index].case_type == '4') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AttorneyAttestedCaseDetailScreen(
                                          caseList![index].id))).then((value) {
                            caseList = null;
                            updateState();
                            selectedCaseType = 2;
                            showProgressDialog(true);
                            apiGetAllCases('2');
                          });
                        } else if (caseList![index].case_type == '10') {
                          print('others 1');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AttorneyNewsPaperCaseDetailScreen(
                                          caseList![index].id))).then((value) {
                            caseList = null;
                            updateState();
                            selectedCaseType = 2;
                            showProgressDialog(true);
                            apiGetAllCases('2');
                          });
                        } else {
                          print('others');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AttorneyCaseDetailScreen(
                                          caseList![index].id))).then((value) {
                            caseList = null;
                            updateState();
                            selectedCaseType = 2;
                            showProgressDialog(true);
                            apiGetAllCases('2');
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 30,
                        width: MediaQuery.of(context).size.width - 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Utility.primaryColor),
                        alignment: Alignment.center,
                        child: Text(
                          'Details >>',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Utility.whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )));
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
                              builder: (context) => LawyerProfileScreen()));
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void apiGetAllCases(type) {
    FocusManager.instance.primaryFocus?.unfocus();
    // print('in request case');
    Map<String, String> headers = Map();
    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';

    // print(GET_ALL_ATTORNEY_CASE_URL + '/' + type);
    http
        .get(Uri.parse(GET_ALL_ATTORNEY_CASE_URL + '/' + type),
            headers: headers)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      // print(mappingResponse);
      if (mappingResponse['success'] == true) {
        if (mappingResponse['data'] != null) {
          caseList = (mappingResponse['data'] as List)
              .map((x) => ModelCase.fromJson(x))
              .toList();
        } else {
          showToast(mappingResponse['message']);
        }
      } else {
        showToast(mappingResponse['message']);
      }
    });
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
}
