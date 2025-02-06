import 'dart:async';
import 'dart:convert';

import 'package:attorney/client/main/home.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserVerificationScreen extends StatefulWidget {
  final String mobile;
  UserVerificationScreen(this.mobile);
  @override
  _UserVerificationScreenState createState() => _UserVerificationScreenState();
}

class _UserVerificationScreenState extends State<UserVerificationScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper =
          Helper(this.context, updateState, showProgressDialog, widget.mobile);
    }

    return Scaffold(
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
  SharedPreferences? preferences;
  int showOtpContainer = 0;

  late FirebaseAuth? auth;

  TextEditingController mobileController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String mobile = '';

  FocusNode mobileFocusNode = FocusNode();
  FocusNode otpFocusNode = FocusNode();

  Helper(this.context, this.updateState, this.showProgressDialog, this.mobile) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
    auth = FirebaseAuth.instance;
    mobileController.text = mobile;
  }

  Widget safeBarContainer() {
    return Container(
      height: MediaQuery.of(context).padding.bottom,
      width: MediaQuery.of(context).size.width,
      color: Utility.primaryColor,
    );
  }

  Widget statusBarContainer() {
    return Container(
      height: MediaQuery.of(context).padding.top,
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
          Container(alignment: Alignment.centerLeft, width: 40, child: null),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 45,
              child: Text(
                'User Verification',
                style: TextStyle(
                    color: Utility.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(alignment: Alignment.centerLeft, width: 40, child: null),
        ],
      ),
    );
  }

  Widget bodyContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mobile No.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.only(right: 10, left: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Utility.textBoxBorderColor, width: 1),
            ),
            width: MediaQuery.of(context).size.width,
            height: 55,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.next,
                    onTap: () {
                      FocusScope.of(context).requestFocus(mobileFocusNode);
                    },
                    onSubmitted: (value) {
                      // FocusScope.of(context)
                      //     .requestFocus(shippingAddressFocusNode);
                    },
                    readOnly: true,
                    focusNode: mobileFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Mobile No.'.toUpperCase(),
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Utility.textBoxBorderColor,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Utility.textBlackColor,
                    ),
                    maxLines: 1,
                    controller: mobileController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          showOtpContainer == 1
              ? Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.only(right: 10, left: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Utility.textBoxBorderColor, width: 1),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          onTap: () {
                            FocusScope.of(context).requestFocus(otpFocusNode);
                          },
                          onSubmitted: (value) {
                            // FocusScope.of(context)
                            //     .requestFocus(shippingAddressFocusNode);
                          },
                          focusNode: otpFocusNode,
                          cursorColor: Utility.textBlackColor,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter 6-digit OTP Code'.toUpperCase(),
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Utility.textBoxBorderColor,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Utility.textBlackColor,
                          ),
                          maxLines: 1,
                          controller: otpController,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),

          ///////////////////////////////////////////////
          showOtpContainer == 0
              ? getOtpButtonContainer()
              : verifyOtpButtonContainer(),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget getOtpButtonContainer() {
    return InkWell(
      onTap: () {
        getOtp();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Utility.primaryColor,
          borderRadius: BorderRadius.circular(100),
        ),
        height: 55,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Text(
          'Get Otp'.toUpperCase(),
          style: TextStyle(
              fontSize: 18,
              color: Utility.textWhiteColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget verifyOtpButtonContainer() {
    return InkWell(
      onTap: () {
        if (otpController.text.length == 0) {
          showToast('Please enter the OTP');
        } else if (otpController.text.length < 6) {
          showToast('Please enter the correct OTP');
        } else {
          otpVerification();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Utility.primaryColor,
          borderRadius: BorderRadius.circular(100),
        ),
        height: 55,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Text(
          'Verify OTP'.toUpperCase(),
          style: TextStyle(
              fontSize: 18,
              color: Utility.textWhiteColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void validations() {
    if (mobileController.text == '') {
      showToast('Please enter the mobile');
    } else if (otpController.text == '') {
      showToast('Please enter the OTP');
    } else {
      apiVerification();
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

  void getOtp() async {
    String mobile = mobileController.text;
    showProgressDialog(true);
    print('in otp');
    await auth!.verifyPhoneNumber(
      phoneNumber: '+92' + mobile.substring(1),
      verificationCompleted: (PhoneAuthCredential credential) async {
        print(credential);
        showProgressDialog(false);
      },
      verificationFailed: (FirebaseAuthException e) {
        showToast(e.message.toString());
        showProgressDialog(false);
      },
      codeSent: (String verificationId, int? resendToken) {
        Utility.verificationId = verificationId;
        print(verificationId);
        showProgressDialog(false);
        showOtpContainer = 1;
        updateState();
        // Navigator.push(context, MaterialPageRoute(builder: (context) => Otp(countryCode, phoneNumber)));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> otpVerification() async {
    showProgressDialog(true);
    FirebaseAuth auth2 = FirebaseAuth.instance;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: Utility.verificationId.toString(),
        smsCode: otpController.text.trim());
    try {
      await auth2.signInWithCredential(credential).then((value) {
        showProgressDialog(false);
        print(value);
        apiVerification();
      });
      print("successful");
    } on FirebaseAuthException catch (e) {
      showProgressDialog(false);
      showToast(e.message.toString());
    } catch (e) {
      showProgressDialog(false);
      showToast(e.toString());
    }
    print(credential);
  }

  void apiVerification() {
    FocusManager.instance.primaryFocus?.unfocus();
    showProgressDialog(true);
    print('in registration');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Accept'] = 'application/json';
    headers['Authorization'] = Utility.modelUser!.token;
    params['mobile'] = mobileController.text;

    print(VERIFY_USER_URL);
    print('params');
    print(params);
    http
        .post(Uri.parse(VERIFY_USER_URL), body: params, headers: headers)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      if (mappingResponse['success'] == true) {
        print(mappingResponse);
        if (mappingResponse['data']['user'] == 'customer') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ClientHomeScreen()),
              (route) => false);
        }
        updateState();
        showToast(mappingResponse['message']);
      } else {
        if (response.statusCode != 200) {
          showToast(mappingResponse['message']);
        }
      }
    });
  }
}
