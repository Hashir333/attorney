import 'dart:async';
import 'dart:convert';
import 'package:attorney/attorney/requestedCases/AttorneyCasesMain.dart';
import 'package:attorney/auth/forgotPassword.dart';
import 'package:attorney/auth/registrationClient.dart';
import 'package:attorney/auth/registrationLawyer.dart';
import 'package:attorney/auth/userVerification.dart';
import 'package:attorney/client/main/home.dart';
import 'package:attorney/models/setting.dart';
import 'package:attorney/models/user.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(this.context, updateState, showProgressDialog);
    }

    return Scaffold(
      backgroundColor: Utility.whiteColor,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading, // Bind loading state to ModalProgressHUD
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).padding.top + 55,
                  width: MediaQuery.of(context).size.width,
                ),
                helper!.logoContainer(),
                Expanded(
                    child: ListView(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: [helper!.bodyContainer()],
                    ))
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
        _isLoading = value;
      });
    }
  }
}

class Helper {
  BuildContext context;
  late Function updateState, showProgressDialog;
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  SharedPreferences? preferences;
  // FirebaseAuth? auth;

  Helper(this.context, this.updateState, this.showProgressDialog) {
    // auth = FirebaseAuth.instance;

    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
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

  Widget logoContainer() {
    return Container(
      // height: MediaQuery.of(context).size.height/2,
      // width: MediaQuery.of(context).size.width/2,
      child: Image.asset(
        Utility.logo,
        height: 300,
        width: 300,
      ),
    );
  }

  Widget bodyContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          phoneNumberContainer(),
          SizedBox(height: 20),
          passwordContainer(),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen()));
            },
            child: Container(
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width,
              height: 30,
              child: Text(
                'Forgot your password?',
                style: TextStyle(
                    color: Utility.textBlackColor,
                    fontSize: 15,
                    fontFamily: 'medium'),
              ),
            ),
          ),
          SizedBox(height: 10),
          loginButtonContainer(),
          SizedBox(height: 20),
          registerButtonContainer()
        ],
      ),
    );
  }

  Widget phoneNumberContainer() {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Utility.textBoxBorderColor, width: 1),
          color: Utility.whiteColor),
      width: MediaQuery.of(context).size.width,
      height: 55,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.done,
              onTap: () {
                FocusScope.of(context).requestFocus(phoneNumberFocusNode);
              },
              onSubmitted: (value) {
                FocusScope.of(context).requestFocus(passwordFocusNode);
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(11),
              ],
              focusNode: phoneNumberFocusNode,
              cursorColor: Utility.textBlackColor,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '03xxxxxxxxx'.toUpperCase(),
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
              controller: phoneNumberController,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordContainer() {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Utility.textBoxBorderColor, width: 1),
          color: Utility.whiteColor),
      width: MediaQuery.of(context).size.width,
      height: 55,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.done,
              onTap: () {
                FocusScope.of(context).requestFocus(passwordFocusNode);
              },
              onSubmitted: (value) {
                // FocusScope.of(context).requestFocus(passwordNode);
              },
              obscureText: true,
              focusNode: passwordFocusNode,
              cursorColor: Utility.textBlackColor,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'XXXXXX'.toUpperCase(),
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
              controller: passwordController,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget loginButtonContainer() {
    return InkWell(
      onTap: () {
        checkValidations();
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ClientHomeScreen()), (route) => false);
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
          'Login'.toUpperCase(),
          style: TextStyle(
              fontSize: 18,
              color: Utility.textWhiteColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget registerButtonContainer() {
    return InkWell(
      onTap: () {
        showRegistrationDialogBox();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        height: 55,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account?'.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
                color: Utility.textBlackColor,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'register'.toUpperCase(),
              style: TextStyle(
                  fontSize: 16,
                  color: Utility.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showRegistrationDialogBox() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Utility.whiteColor,
          content: Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: Text(
                          'Register As',
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        )),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RegistrationClientScreen()));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Utility.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width / 3.5,
                        child: Text(
                          'Customer'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Utility.whiteColor),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RegistrationLawyerScreen()));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Utility.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width / 3.5,
                        child: Text(
                          'Attorney'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Utility.whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void getOtp() async{
  //   if(phoneNumberController.text[0] == '0'){
  //     phoneNumberController.text = '+92' + phoneNumberController.text.substring(1);
  //   }
  //   showProgressDialog(true);
  //   await auth!.verifyPhoneNumber(
  //     phoneNumber: phoneNumberController.text,
  //     verificationCompleted: (PhoneAuthCredential credential) async{
  //       print(credential);
  //       showProgressDialog(false);
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       showToast(e.message.toString());
  //       showProgressDialog(false);
  //     },
  //     codeSent: (String verificationId, int? resendToken) {
  //       Utility.verificationId = verificationId;
  //       print(verificationId);
  //       showProgressDialog(false);
  //       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => VerificationScreen(phoneNumberController.text)), (route) => false);
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {},
  //   );
  // }

  void checkValidations() {
    if (phoneNumberController.text == '') {
      showToast('Please enter Mobile Number');
    } else if (passwordController.text == '') {
      showToast('Please enter Password');
    } else {
      apiLogin();
    }
  }

  void apiLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    showProgressDialog(true);
    print('in login');
    Map<String, String> params = Map();

    params['mobile'] = phoneNumberController.text;
    params['password'] = passwordController.text;

    print(LOGIN_URL);
    print(params);
    http.post(Uri.parse(LOGIN_URL), body: params).then((response) async {
      apiGetSettings();
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);

      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        if (mappingResponse['data']['user_type'] == 'attorney' &&
            mappingResponse['data']['status'] == 1) {
          showToast(mappingResponse['message']);
        } else {
          Utility.modelUser = ModelUser.fromJson(mappingResponse['data']);
          preferences!.setBool('isLoggedIn', true).then((isEmailSet) {
            preferences!
                .setString('mobile', phoneNumberController.text)
                .then((isEmailSet) {
              preferences!
                  .setString('password', passwordController.text)
                  .then((isPasswordSet) {
                Utility.userLoggedIn = true;
                if (mappingResponse['data']['user_type'] == 'attorney') {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AttorneyCasesMainScreen()),
                          (route) => false);
                } else if (mappingResponse['data']['user_type'] == 'customer' &&
                    mappingResponse['data']['status'] == 2) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserVerificationScreen(
                              phoneNumberController.text)));
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientHomeScreen()),
                          (route) => false);
                }
                updateState();
              });
            });
          });
        }
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void apiGetSettings() {
    Map<String, String> header = Map();

    header['Accept'] = 'application/json';

    http
        .get(Uri.parse(GET_SETTINGS_URL), headers: header)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        Utility.modelDistrict = (mappingResponse['data']['districts'] as List)
            .map((x) => ModelDistrict.fromJson(x))
            .toList();
        Utility.modelCourt = (mappingResponse['data']['courts'] as List)
            .map((x) => ModelCourt.fromJson(x))
            .toList();

        updateState();
      } else if (mappingResponse['success'] == false) {}
    });
  }
}