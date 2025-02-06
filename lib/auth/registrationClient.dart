import 'dart:convert';

import 'package:attorney/client/main/home.dart';
import 'package:attorney/models/user.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegistrationClientScreen extends StatefulWidget {
  @override
  _RegistrationClientScreenState createState() =>
      _RegistrationClientScreenState();
}

class _RegistrationClientScreenState extends State<RegistrationClientScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(this.context, updateState, showProgressDialog);
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
        _isLoading = value;
      });
    }
  }
}

class Helper {
  BuildContext context;
  late Function updateState, showProgressDialog;
  SharedPreferences? preferences;

  TextEditingController nameController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmEmailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController confirmMobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController shippingAddressController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode cnicFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode confirmEmailFocusNode = FocusNode();
  FocusNode mobileFocusNode = FocusNode();
  FocusNode confirmMobileFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode shippingAddressFocusNode = FocusNode();

  Helper(this.context, this.updateState, this.showProgressDialog) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
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
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
                alignment: Alignment.centerLeft,
                width: 40,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Utility.whiteColor,
                )),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 45,
              child: Text(
                'Customer Registration',
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
              'Full Name',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                      FocusScope.of(context).requestFocus(nameFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(cnicFocusNode);
                    },
                    focusNode: nameFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Full Name'.toUpperCase(),
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
                    controller: nameController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'CNIC',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                      FocusScope.of(context).requestFocus(cnicFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(emailFocusNode);
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(13),
                    ],
                    focusNode: cnicFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'CNIC'.toUpperCase(),
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
                    controller: cnicController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Email',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                      FocusScope.of(context).requestFocus(emailFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(confirmEmailFocusNode);
                    },
                    focusNode: emailFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'email'.toUpperCase(),
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
                    controller: emailController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Confirm Email',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                      FocusScope.of(context)
                          .requestFocus(confirmEmailFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(mobileFocusNode);
                    },
                    focusNode: confirmEmailFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirm email'.toUpperCase(),
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
                    controller: confirmEmailController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
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
                      FocusScope.of(context)
                          .requestFocus(confirmMobileFocusNode);
                    },
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
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Confirm Mobile No.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                      FocusScope.of(context)
                          .requestFocus(confirmMobileFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                    focusNode: confirmMobileFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirm Mobile No.'.toUpperCase(),
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
                    controller: confirmMobileController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Password',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(confirmPasswordFocusNode);
                    },
                    focusNode: passwordFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password'.toUpperCase(),
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
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Confirm Password',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                      FocusScope.of(context)
                          .requestFocus(confirmPasswordFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(shippingAddressFocusNode);
                    },
                    focusNode: confirmPasswordFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirm Password.'.toUpperCase(),
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
                    controller: confirmPasswordController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Shipping Address',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
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
                    textInputAction: TextInputAction.done,
                    onTap: () {
                      FocusScope.of(context)
                          .requestFocus(shippingAddressFocusNode);
                    },
                    onSubmitted: (value) {
                      // FocusScope.of(context).requestFocus(passwordNode);
                    },
                    focusNode: shippingAddressFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Shipping Address'.toUpperCase(),
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
                    controller: shippingAddressController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          registerButtonContainer(),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget registerButtonContainer() {
    return InkWell(
      onTap: () {
        validations();
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
          'Register Now'.toUpperCase(),
          style: TextStyle(
              fontSize: 18,
              color: Utility.textWhiteColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void validations() {
    if (nameController.text == '') {
      showToast('Please enter the name');
    } else if (cnicController.text == '') {
      showToast('Please enter the cnic');
    } else if (emailController.text == '') {
      showToast('Please enter the email');
    } else if (confirmEmailController.text == '') {
      showToast('Please enter the confirm email');
    } else if (confirmEmailController.text != emailController.text) {
      showToast('Please enter the correct email');
    } else if (mobileController.text == '') {
      showToast('Please enter the mobile');
    } else if (confirmMobileController.text == '') {
      showToast('Please enter the confirm mobile');
    } else if (confirmMobileController.text != mobileController.text) {
      showToast('Please enter the correct mobile');
    } else if (passwordController.text == '') {
      showToast('Please enter the password');
    } else if (passwordController.text.length < 6) {
      showToast('Password length should be 6-digit');
    } else if (confirmPasswordController.text == '') {
      showToast('Please enter the confirm password');
    } else if (confirmPasswordController.text != passwordController.text) {
      showToast('Please enter the correct password');
    } else if (shippingAddressController.text == '') {
      showToast('Please enter the shipping address');
    } else {
      apiRegistration();
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

  void apiRegistration() {
    FocusManager.instance.primaryFocus?.unfocus();
    showProgressDialog(true);
    print('in registration');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Accept'] = 'application/json';

    params['mobile'] = mobileController.text;
    params['password'] = passwordController.text;
    params['name'] = nameController.text;
    params['cnic'] = cnicController.text;
    params['email'] = emailController.text;
    params['shipping_address'] = shippingAddressController.text;
    params['user_type'] = 'customer';

    print(REGISTRATION_URL);
    print(params);
    http
        .post(Uri.parse(REGISTRATION_URL), body: params, headers: headers)
        .then((response) async {
      print(response.statusCode);
      print(response.body);
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      if (mappingResponse['success'] == true) {
        Utility.modelUser = ModelUser.fromJson(mappingResponse['data']);
        preferences!.setBool('isLoggedIn', true).then((isEmailSet) {
          preferences!
              .setString('mobile', mobileController.text)
              .then((isEmailSet) {
            preferences!
                .setString('password', passwordController.text)
                .then((isPasswordSet) {
              Utility.userLoggedIn = true;
              showToast(mappingResponse['message']);

              // if(mappingResponse['data']['user_type'] == 'customer' && mappingResponse['data']['status'] == 2){
              //   Navigator.pushAndRemoveUntil(context,
              //   MaterialPageRoute(builder: (context) => UserVerificationScreen(mobileController.text)), (
              //       route) => false);
              // }
              // else{
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ClientHomeScreen()),
                      (route) => false);
              // }

              updateState();
            });
          });
        });
      } else {
        if (response.statusCode != 200) {
          if (mappingResponse['errors'].containsKey('mobile')) {
            showToast(mappingResponse['errors']['mobile'][0]);
          } else if (mappingResponse['errors'].containsKey('email')) {
            showToast(mappingResponse['errors']['email'][0]);
          }
        }
      }
    });
  }
}