import 'dart:async';
import 'dart:io';

import 'package:attorney/models/setting.dart';
import 'package:attorney/models/user.dart';
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

class LawyerProfileScreen extends StatefulWidget {
  @override
  _LawyerProfileScreenState createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
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
        _isLoading =
            value; // Update loading state to show or hide the modal progress HUD
      });
    }
  }
}

class Helper {
  BuildContext context;
  late Function updateState, showProgressDialog;
  int accountIndex = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
  FocusNode passwordFocusNode = FocusNode();
  FocusNode shippingAddressFocusNode = FocusNode();
  FocusNode officeAddressFocusNode = FocusNode();
  FocusNode courtsFocusNode = FocusNode();
  FocusNode accountFocusNode = FocusNode();
  FocusNode bankAccountFocusNode = FocusNode();
  FocusNode bankTitleFocusNode = FocusNode();
  FocusNode bankNameFocusNode = FocusNode();

  int selectedCourtIndex = 0;
  ImagePicker _picker = ImagePicker();
  XFile? imageIdCardFront = null;
  XFile? imageIdCardback = null;
  XFile? imageClerkCard = null;
  SharedPreferences? preferences;

  Helper(this.context, this.updateState, this.showProgressDialog) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
    nameController.text = Utility.modelUser!.name;
    cnicController.text = Utility.modelUser!.cnic;
    emailController.text = Utility.modelUser!.email;
    mobileController.text = Utility.modelUser!.mobile;
    shippingAddressController.text = Utility.modelUser!.shipping_address;
    officeAddressController.text = Utility.modelUser!.office_address;
    selectedCourtIndex = Utility.modelDistrict!
        .indexWhere((element) => element.name == Utility.modelUser!.courts);
    accountIndex = Utility.paymentMethods
        .indexWhere((element) => element == Utility.modelUser!.account_title);

    if (accountIndex < 0) {
      accountIndex = 0;
    }
    print(accountIndex);
    if (accountIndex == 1 || accountIndex == 2) {
      accountController.text = Utility.modelUser!.account_no;
    } else {
      bankAccountController.text = Utility.modelUser!.bank_account_no;
      bankTitleController.text = Utility.modelUser!.bank_account_title;
      bankNameController.text = Utility.modelUser!.bank_name;
    }
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
                'Attorney Details',
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
                    readOnly: true,
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
                    readOnly: true,
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
                    onTap: () {},
                    onSubmitted: (value) {},
                    readOnly: true,
                    // focusNode: mobileFocusNode,
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
                    readOnly: true,
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
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Utility.primaryColor,
          borderRadius: BorderRadius.circular(100),
        ),
        height: 55,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Text(
          'update'.toUpperCase(),
          style: TextStyle(
              fontSize: 16,
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

  void validations() {
    if (nameController.text == '') {
      showToast('Please enter the name');
    } else if (shippingAddressController.text == '') {
      showToast('Please enter the shipping address');
    } else if (officeAddressController.text == '') {
      showToast('Please enter the office address');
    } else if (selectedCourtIndex == 0) {
      showToast('Please select the court');
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
    headers['Authorization'] = Utility.modelUser!.token;

    params['mobile'] = mobileController.text;
    params['password'] = passwordController.text;
    params['name'] = nameController.text;
    params['cnic'] = cnicController.text;
    params['email'] = emailController.text;
    params['shipping_address'] = shippingAddressController.text;
    params['office_address'] = officeAddressController.text;
    params['account_no'] = accountController.text;
    params['account_title'] = Utility.paymentMethods[accountIndex];
    params['bank_account_title'] = bankTitleController.text;
    params['bank_name'] = bankNameController.text;
    params['bank_account_no'] = bankAccountController.text;
    params['courts'] = Utility.modelDistrict![selectedCourtIndex].name;
    params['user_type'] = 'attorney';
    // params['id_card_front'] =  await MultipartFile.fromFile(imageIdCardFront!.path, filename: imageIdCardFront!.path.split('/').last);
    // params['id_card_back'] =  await MultipartFile.fromFile(imageIdCardback!.path, filename: imageIdCardback!.path.split('/').last);
    // params['clerk_card'] =  await MultipartFile.fromFile(imageClerkCard!.path, filename: imageClerkCard!.path.split('/').last);

    print(UPDATE_USER_URL);
    print(params);

    String token = Utility.modelUser!.token;

    FormData formData = FormData.fromMap(params);
    Dio dio = new Dio();
    dio
        .post(UPDATE_USER_URL,
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
        Utility.modelUser = ModelUser.fromJson(mappingResponse['data']);
        Utility.modelUser!.token = token;
        showToast(mappingResponse['message']);
        Navigator.of(context).pop();
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
