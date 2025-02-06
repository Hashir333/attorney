// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';

import 'package:attorney/client/requestedCases/RequestNewPaperCaseDetails.dart';
import 'package:attorney/models/case.dart';
import 'package:attorney/models/setting.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';

class NewsPaperAdScreen extends StatefulWidget {
  @override
  _NewsPaperAdScreenState createState() => _NewsPaperAdScreenState();
}

class _NewsPaperAdScreenState extends State<NewsPaperAdScreen> {
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

  int selectedCourtIndex = 0;

  ImagePicker _picker = ImagePicker();
  List<XFile>? caseImageList = [];
  ModelCase? submittedCase = null;

  TextEditingController titleController = TextEditingController();
  TextEditingController jugdeController = TextEditingController();
  TextEditingController newPaperNameController = TextEditingController();
  TextEditingController partiesNameController = TextEditingController();
  TextEditingController lastHearingDateController = TextEditingController();
  TextEditingController nextHearingDateController = TextEditingController();
  TextEditingController attorneyGuidanceController = TextEditingController();
  TextEditingController noOfDefendantController = TextEditingController();

  FocusNode titleFocusNode = FocusNode();
  FocusNode jugdeFocusNode = FocusNode();
  FocusNode newPaperNameFocusNode = FocusNode();
  FocusNode partiesNameFocusNode = FocusNode();
  FocusNode attorneyGuidanceFocusNode = FocusNode();
  FocusNode noOfDefendantFocusNode = FocusNode();

  Helper(this.context, this.updateState, this.showProgressDialog) {
    Utility.modelDistrict![0].name = 'Select Court';
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
                'News Paper Ads'.toUpperCase(),
                style: TextStyle(
                    color: Utility.whiteColor,
                    fontSize: 17,
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
          casesBodyContainer(),
          ///////////////////////////////////////////////
          SizedBox(
            height: 20,
          ),
          submitButtonContainer(),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget casesBodyContainer() {
    return Container(
      child: Column(
        children: [
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
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Title of Case',
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
                      FocusScope.of(context).requestFocus(titleFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(jugdeFocusNode);
                    },
                    focusNode: titleFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Abc vs Xyz'.toUpperCase(),
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
                    controller: titleController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Name of Judge',
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
                      FocusScope.of(context).requestFocus(jugdeFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(newPaperNameFocusNode);
                    },
                    focusNode: jugdeFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Mr. Abc Civil Judge etc'.toUpperCase(),
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
                    controller: jugdeController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Name of Newspaper',
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
                          .requestFocus(newPaperNameFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(partiesNameFocusNode);
                    },
                    focusNode: newPaperNameFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'ENTER FULL NAME OF NEWSPAPER'.toUpperCase(),
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
                    controller: newPaperNameController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Parties Name, Father Name & Address',
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
                      FocusScope.of(context).requestFocus(partiesNameFocusNode);
                    },
                    onSubmitted: (value) {
                      // FocusScope.of(context).requestFocus(passwordNode);
                    },
                    focusNode: partiesNameFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Abc S/O of Xyz R/O House No. Abc, District etc'
                          .toUpperCase(),
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
                    controller: partiesNameController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Last date of Hearing',
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
                    readOnly: true,
                    textInputAction: TextInputAction.done,
                    onTap: () {
                      _selectDate(lastHearingDateController, 'date');
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(attorneyGuidanceFocusNode);
                    },
                    // focusNode: verificationNumberFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Select the Last Date of Your Case'.toUpperCase(),
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
                    controller: lastHearingDateController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Next date of Hearing',
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
                    readOnly: true,
                    textInputAction: TextInputAction.done,
                    onTap: () {
                      _selectDate(nextHearingDateController, 'date');
                    },
                    onSubmitted: (value) {},
                    // focusNode: verificationNumberFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Next Date of Your Case'.toUpperCase(),
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
                    controller: nextHearingDateController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enter the serial number of Defendant',
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
                          .requestFocus(noOfDefendantFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(attorneyGuidanceFocusNode);
                    },
                    focusNode: noOfDefendantFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'ENTER THE SERIAL NUMBER OF DEFENDANT WHOM YOU WANT TO SUMMON: 1, 3, 9 etc'
                              .toUpperCase(),
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
                    controller: noOfDefendantController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Any guidance for Attorney',
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
                          .requestFocus(attorneyGuidanceFocusNode);
                    },
                    onSubmitted: (value) {
                      // FocusScope.of(context).requestFocus(passwordNode);
                    },
                    focusNode: attorneyGuidanceFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'You can write any special instructions here for Attorney'
                              .toUpperCase(),
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
                    controller: attorneyGuidanceController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Attach front pages of case (Image should include parties name clearly)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          caseImageList!.length == 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        getImages();
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
                                'Add Images',
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
              : Container(
                  height: caseImageList!.length == 0 ? 0 : 170,
                  width: MediaQuery.of(context).size.width,
                  child: caseImageListView()),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////////////////////////
        ],
      ),
    );
  }

  Widget submitButtonContainer() {
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
          'submit'.toUpperCase(),
          style: TextStyle(
              fontSize: 18,
              color: Utility.textWhiteColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget caseImageListView() {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemBuilder: caseImageListViewContainer,
        itemCount: caseImageList != null
            ? (caseImageList!.length > 0 ? caseImageList!.length : 0)
            : 0,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  Widget caseImageListViewContainer(BuildContext context, int index) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 150,
          width: 100,
          child: Image.file(
            File(caseImageList![index].path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            top: 5,
            left: 80,
            child: InkWell(
              onTap: () {
                caseImageList!.removeAt(index);
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

  Future<Null> _selectDate(defaultDateController, dateType) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Utility.primaryColor, // header background color
                  onPrimary: Utility.textWhiteColor, // header text color
                  onSurface: Utility.selectedColor, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Utility.primaryColor, // button text color
                  ),
                ),
              ),
              child: child!);
        },
        context: context,
        initialDatePickerMode:
            dateType == 'date' ? DatePickerMode.day : DatePickerMode.year,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000, 1),
        lastDate: DateTime.now().add(Duration(days: 4000)));

    if (picked != null) {
      var day = picked.day.toString() + "";
      var month = picked.month.toString() + "";
      var year = picked.year.toString() + "";
      if (day.length == 1) {
        day = "0" + day;
      }
      if (month.length == 1) {
        month = "0" + month;
      }

      if (dateType == 'date') {
        defaultDateController.text = DateFormat('dd MMMM yyyy').format(picked);
      } else {
        defaultDateController.text = year;
      }
    }
  }

  void validations() {
    if (selectedCourtIndex == 0) {
      showToast('Please select the Court');
    } else if (titleController.text == '') {
      showToast('Please enter the Title');
    } else if (jugdeController.text == '') {
      showToast('Please enter the Judge');
    } else if (partiesNameController.text == '') {
      showToast('Please enter the Parties name');
    } else if (lastHearingDateController.text == '') {
      showToast('Please enter the Last hearing date');
    } else if (nextHearingDateController.text == '') {
      showToast('Please enter the Next hearing date');
    } else if (noOfDefendantController.text == '') {
      showToast('Please enter the number of defendant whom you want to summon');
    } else if (caseImageList == null && caseImageList!.length == 0) {
      showToast('Please Attach Front Pages of Case (include parties name)');
    } else {
      apiRequestCase();
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

  Future<void> showRegistrationDialogBox(message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
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
                    Navigator.of(context).pop();
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
                // InkWell(
                //   onTap: (){
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentMethodScreen()));
                //   },
                //   child: Container(
                //     alignment: Alignment.center,
                //     decoration: BoxDecoration(
                //       color: Utility.primaryColor,
                //       borderRadius: BorderRadius.circular(5),
                //     ),
                //     height: 55,
                //     width: MediaQuery.of(context).size.width/2.5,
                //     child: Text('View Payment Options'.toUpperCase(),
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Utility.whiteColor
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RequestedNewPaperCaseDetailScreen(
                                    submittedCase!.id)));
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
                      'Payment'.toUpperCase(),
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
          ),
        );
      },
    );
  }

  Future<void> getImages() async {
    try {
      await _picker.pickMultiImage().then((value) {
        if (value != null) {
          caseImageList!.addAll(value);
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

  void apiRequestCase() async {
    FocusManager.instance.primaryFocus?.unfocus();
    showProgressDialog(true);
    print('in request case');
    Map<String, String> headers = Map();
    Map<String, dynamic> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    params['case_type'] = '10';
    params['court_name'] = Utility.modelDistrict![selectedCourtIndex].name;
    params['title'] = titleController.text;
    params['judge_name'] = jugdeController.text;
    params['parties_name'] = partiesNameController.text;
    params['last_date_hearing'] = lastHearingDateController.text;
    params['next_date_hearing'] = nextHearingDateController.text;
    params['comment_for_attorney'] = attorneyGuidanceController.text;
    if (caseImageList != null && caseImageList!.length > 0) {
      for (int i = 0; i < caseImageList!.length; i++) {
        params['case_images[$i]'] = await MultipartFile.fromFile(
            caseImageList![i].path,
            filename: caseImageList![i].path.split('/').last);
      }
    }
    params['serial_no_of_defendant'] = noOfDefendantController.text;
    params['news_paper_name'] = newPaperNameController.text;

    FormData formData = FormData.fromMap(params);
    Dio dio = new Dio();
    dio
        .post(REQUEST_CASE_URL,
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
        submittedCase = ModelCase.fromJson(mappingResponse['data']);
        updateState();
        clearFields();
        showRegistrationDialogBox(mappingResponse['message']);
      } else {
        if (response.statusCode != 200) {
          showToast(mappingResponse['message']);
        }
      }
    });
  }

  void clearFields() {
    titleController.clear();
    jugdeController.clear();
    partiesNameController.clear();
    lastHearingDateController.clear();
    nextHearingDateController.clear();
    noOfDefendantController.clear();
    newPaperNameController.clear();
    attorneyGuidanceController.clear();
    caseImageList = [];
    updateState();
  }
}
