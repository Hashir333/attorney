import 'dart:async';
import 'dart:io';
import 'package:attorney/auth/login.dart';
import 'package:attorney/models/setting.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationLawyerScreen extends StatefulWidget {
  @override
  _RegistrationLawyerScreenState createState() =>
      _RegistrationLawyerScreenState();
}

class _RegistrationLawyerScreenState extends State<RegistrationLawyerScreen> {
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

  TextEditingController nameController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmEmailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController confirmMobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController shippingAddressController = TextEditingController();
  TextEditingController officeAddressController = TextEditingController();
  TextEditingController courtsController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  TextEditingController bankAccountController = TextEditingController();
  TextEditingController bankTitleController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode cnicFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode confirmEmailFocusNode = FocusNode();
  FocusNode mobileFocusNode = FocusNode();
  FocusNode confirmMobileFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode shippingAddressFocusNode = FocusNode();
  FocusNode officeAddressFocusNode = FocusNode();
  FocusNode courtsFocusNode = FocusNode();
  FocusNode accountFocusNode = FocusNode();
  FocusNode bankAccountFocusNode = FocusNode();
  FocusNode bankTitleFocusNode = FocusNode();
  FocusNode bankNameFocusNode = FocusNode();

  int selectedCourtIndex = 0;
  int accountIndex = 0;
  ImagePicker _picker = ImagePicker();
  XFile? imageIdCardFront = null;
  XFile? imageIdCardback = null;
  XFile? imageClerkCard = null;
  SharedPreferences? preferences;

  Helper(this.context, this.updateState, this.showProgressDialog) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
    Utility.modelDistrict![0].name = 'Station of Practice';
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
                'Attorney Registration',
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
              'Shipping/Office Address',
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
                          .requestFocus(shippingAddressFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(officeAddressFocusNode);
                    },
                    focusNode: shippingAddressFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Address'.toUpperCase(),
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
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'House Address',
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
                          .requestFocus(officeAddressFocusNode);
                    },
                    onSubmitted: (value) {
                      // FocusScope.of(context).requestFocus(passwordNode);
                    },
                    focusNode: officeAddressFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'House Address'.toUpperCase(),
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
                    controller: officeAddressController,
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
          SizedBox(
            height: 5,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(100)),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<ModelDistrict>(
                  isExpanded: true,
                  items: Utility.modelDistrict!.map((ModelDistrict item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  hint: new Text('Select Court'),
                  onChanged: (v) {
                    selectedCourtIndex = Utility.modelDistrict!.indexOf(v!);
                    updateState();
                  },
                  iconEnabledColor: Utility.textBlackColor,
                  value: Utility.modelDistrict![selectedCourtIndex],
                  style: new TextStyle(
                      color: Utility.textBlackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          ///////////////////////////////////////////////
          SizedBox(
            height: 5,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(100)),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: Utility.paymentMethods.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (Utility.paymentMethods.indexOf(v!) != 0) {
                      accountIndex = Utility.paymentMethods.indexOf(v);
                      updateState();
                    }
                  },
                  iconEnabledColor: Utility.textBlackColor,
                  value: Utility.paymentMethods[accountIndex],
                  style: new TextStyle(
                      color: Utility.textBlackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          (accountIndex == 1 || accountIndex == 2)
              ? Container(
            margin: EdgeInsets.only(bottom: 10),
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
                    textInputAction: TextInputAction.next,
                    onTap: () {
                      FocusScope.of(context)
                          .requestFocus(accountFocusNode);
                    },
                    focusNode: accountFocusNode,
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
                    controller: accountController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          )
              : Container(),
          (accountIndex == 3)
              ? Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(right: 10, left: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Utility.textBoxBorderColor, width: 1),
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
                              .requestFocus(bankTitleFocusNode);
                        },
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(bankNameFocusNode);
                        },
                        focusNode: bankTitleFocusNode,
                        cursorColor: Utility.textBlackColor,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title'.toUpperCase(),
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
                        controller: bankTitleController,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(right: 10, left: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Utility.textBoxBorderColor, width: 1),
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
                              .requestFocus(bankNameFocusNode);
                        },
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(bankAccountFocusNode);
                        },
                        focusNode: bankNameFocusNode,
                        cursorColor: Utility.textBlackColor,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Bank Name'.toUpperCase(),
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
                        controller: bankNameController,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(right: 10, left: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Utility.textBoxBorderColor, width: 1),
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
                              .requestFocus(bankAccountFocusNode);
                        },
                        focusNode: bankAccountFocusNode,
                        cursorColor: Utility.textBlackColor,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Account No.'.toUpperCase(),
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
                        controller: bankAccountController,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              : Container(),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Attachement Front side of ID Card',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          imageIdCardFront == null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  getImages(1);
                },
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey.shade300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Utility.textBlackColor,
                      ),
                      Container(
                        child: Text(
                          'Add Image',
                          style: TextStyle(
                            color: Utility.textBlackColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              : Container(),
          SizedBox(
            height: 10,
          ),
          (imageIdCardFront != null)
              ? Container(
              height: 150,
              // color: Colors.grey.shade300,
              width: MediaQuery.of(context).size.width,
              child: imageIdCardtFrontViewCardContainer())
              : Container(),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Attachement Back side of ID Card',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          imageIdCardback == null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  getImages(2);
                },
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey.shade300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Utility.textBlackColor,
                      ),
                      Container(
                        child: Text(
                          'Add Image',
                          style: TextStyle(
                            color: Utility.textBlackColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              : Container(),
          SizedBox(
            height: 10,
          ),
          (imageIdCardback != null)
              ? Container(
              height: 150,
              // color: Colors.grey.shade300,
              width: MediaQuery.of(context).size.width,
              child: imageIdCardtBackViewCardContainer())
              : Container(),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Attach Bar Card',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          imageClerkCard == null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  getImages(3);
                },
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey.shade300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Utility.textBlackColor,
                      ),
                      Container(
                        child: Text(
                          'Add Image',
                          style: TextStyle(
                            color: Utility.textBlackColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              : Container(),
          SizedBox(
            height: 10,
          ),
          (imageClerkCard != null)
              ? Container(
              height: 150,
              // color: Colors.grey.shade300,
              width: MediaQuery.of(context).size.width,
              child: imageClerkViewCardContainer())
              : Container(),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
          SizedBox(
            height: 20,
          ),
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
          'submit for Registration'.toUpperCase(),
          style: TextStyle(
              fontSize: 18,
              color: Utility.textWhiteColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget imageIdCardtFrontViewCardContainer() {
    return Stack(
      children: [
        Container(
          height: 150,
          width: 100,
          child: Image.file(
            File(imageIdCardFront!.path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            top: 5,
            left: 80,
            child: InkWell(
              onTap: () {
                imageIdCardFront = null;
                updateState();
              },
              child: Container(
                decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                height: 20,
                width: 20,
                child: Icon(
                  Icons.close,
                  size: 15,
                ),
              ),
            ))
      ],
    );
  }

  Widget imageIdCardtBackViewCardContainer() {
    return Stack(
      children: [
        Container(
          height: 150,
          width: 100,
          child: Image.file(
            File(imageIdCardback!.path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            top: 5,
            left: 80,
            child: InkWell(
              onTap: () {
                imageIdCardback = null;
                updateState();
              },
              child: Container(
                decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                height: 20,
                width: 20,
                child: Icon(
                  Icons.close,
                  size: 15,
                ),
              ),
            ))
      ],
    );
  }

  Widget imageClerkViewCardContainer() {
    return Stack(
      children: [
        Container(
          height: 150,
          width: 100,
          child: Image.file(
            File(imageClerkCard!.path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            top: 5,
            left: 80,
            child: InkWell(
              onTap: () {
                imageClerkCard = null;
                updateState();
              },
              child: Container(
                decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                height: 20,
                width: 20,
                child: Icon(
                  Icons.close,
                  size: 15,
                ),
              ),
            ))
      ],
    );
  }

  Future<void> getImages(imageType) async {
    try {
      await _picker
          .pickImage(
          source: ImageSource.gallery,
          preferredCameraDevice: CameraDevice.rear)
          .then((value) {
        if (value != null) {
          if (imageType == 1) {
            imageIdCardFront = value;
          } else if (imageType == 2) {
            imageIdCardback = value;
          } else if (imageType == 3) {
            imageClerkCard = value;
          }
          updateState();
          print('i am in');
        } else {
          print("No image is selected.");
          return;
        }
      });
    } catch (e) {
      print(e);
    }
    updateState();
  }

  Future<void> showRegistrationDialogBox(message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Utility.whiteColor,
          content: Container(
            height: 430,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                            (route) => false);
                  },
                  child: Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width,
                      child: Icon(Icons.close)),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: Text(
                      'Request Generated Successfully',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                SizedBox(
                  height: 20,
                ),
                Container(
                    child: Text(
                      message,
                      maxLines: 15,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.8,
                      ),
                    )),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        );
      },
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
    } else if (confirmPasswordController.text == '') {
      showToast('Please enter the confirm password');
    } else if (confirmPasswordController.text != passwordController.text) {
      showToast('Please enter the correct password');
    } else if (shippingAddressController.text == '') {
      showToast('Please enter the shipping address');
    } else if (officeAddressController.text == '') {
      showToast('Please enter the office address');
    } else if (selectedCourtIndex == 0) {
      showToast('Please select the court');
    } else if (accountIndex == 0) {
      showToast('Please select the Account No.');
    } else if ((accountIndex == 1 || accountIndex == 2) &&
        accountController.text == '') {
      showToast('Please enter the Account No.');
    } else if ((accountIndex == 3) && bankTitleController.text == '') {
      showToast('Please enter the Title');
    } else if ((accountIndex == 3) && bankNameController.text == '') {
      showToast('Please enter the Bank Name');
    } else if ((accountIndex == 3) && bankAccountController.text == '') {
      showToast('Please enter the Bank Account No.');
    } else if (imageIdCardFront == null) {
      showToast('Please add the ID card front image');
    } else if (imageIdCardback == null) {
      showToast('Please add the ID card back image');
    } else if (imageClerkCard == null) {
      showToast('Please add the Clerk card image');
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

  void apiRegistration() async {
    FocusManager.instance.primaryFocus?.unfocus();
    showProgressDialog(true);
    print('in attorney registration');
    Map<String, String> headers = Map();
    Map<String, dynamic> params = Map();

    headers['Accept'] = 'application/json';

    params['mobile'] = mobileController.text;
    params['password'] = passwordController.text;
    params['name'] = nameController.text;
    params['cnic'] = cnicController.text;
    params['email'] = emailController.text;
    params['shipping_address'] = shippingAddressController.text;
    params['office_address'] = officeAddressController.text;
    params['account_no'] = accountController.text;
    params['account_title'] =
    accountIndex != 3 ? Utility.paymentMethods[accountIndex] : '';
    params['bank_account_title'] = bankTitleController.text;
    params['bank_name'] = bankNameController.text;
    params['bank_account_no'] = bankAccountController.text;
    params['courts'] = Utility.modelDistrict![selectedCourtIndex].name;
    params['user_type'] = 'attorney';
    params['id_card_front'] = await MultipartFile.fromFile(
        imageIdCardFront!.path,
        filename: imageIdCardFront!.path.split('/').last);
    params['id_card_back'] = await MultipartFile.fromFile(imageIdCardback!.path,
        filename: imageIdCardback!.path.split('/').last);
    params['clerk_card'] = await MultipartFile.fromFile(imageClerkCard!.path,
        filename: imageClerkCard!.path.split('/').last);

    print(REGISTRATION_URL);
    print(params);

    FormData formData = FormData.fromMap(params);
    Dio dio = new Dio();
    dio
        .post(REGISTRATION_URL,
        data: formData,
        options: Options(
          method: 'POST',
          headers: headers,
          responseType: ResponseType.json,
          followRedirects: false,
          validateStatus: (status) {
            showProgressDialog(false);
            updateState();
            return status! <= 500;
          },
          sendTimeout: Duration(milliseconds: 60000),
        ))
        .then((response) {
      showProgressDialog(false);
      var mappingResponse = response.data;
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        showRegistrationDialogBox(mappingResponse['message']);
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