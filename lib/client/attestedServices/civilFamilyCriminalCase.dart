import 'dart:async';
import 'dart:convert';

import 'package:attorney/client/requestedCases/RequestAttestedCaseDetails.dart';
import 'package:attorney/models/case.dart';
import 'package:attorney/models/setting.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CivilFamilyCriminalCaseScreen extends StatefulWidget {
  final int caseType;
  final String caseTypeName;
  CivilFamilyCriminalCaseScreen(this.caseType, this.caseTypeName);
  @override
  _CivilFamilyCriminalCaseScreenState createState() =>
      _CivilFamilyCriminalCaseScreenState();
}

class _CivilFamilyCriminalCaseScreenState
    extends State<CivilFamilyCriminalCaseScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(this.context, updateState, showProgressDialog,
          widget.caseType, widget.caseTypeName);
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
  String caseTypeName;
  int caseType;

  int caseSelectedStatusIndex = 0;
  int selectedCourtIndex = 0;
  ModelCase? submittedCase = null;

  var caseStatus = [
    'Select Case Status',
    'Pending',
    'Decided',
  ];

  TextEditingController titleController = TextEditingController();
  TextEditingController jugdeController = TextEditingController();
  TextEditingController lastHearingDateController = TextEditingController();
  TextEditingController nextHearingDateController = TextEditingController();
  TextEditingController caseNoController = TextEditingController();
  TextEditingController caseYearController = TextEditingController();
  TextEditingController decisionDateController = TextEditingController();
  TextEditingController requiredDocumentController = TextEditingController();
  TextEditingController whichSideWeAreController = TextEditingController();
  TextEditingController setOfCopiesRequiredController = TextEditingController();
  TextEditingController kuliyaNoController = TextEditingController();
  TextEditingController attorneyGuidanceController = TextEditingController();

  FocusNode titleFocusNode = FocusNode();
  FocusNode jugdeFocusNode = FocusNode();
  FocusNode caseNoFocusNode = FocusNode();
  FocusNode caseYearFocusNode = FocusNode();
  FocusNode requiredDocumentFocusNode = FocusNode();
  FocusNode whichSideWeAreFocusNode = FocusNode();
  FocusNode setOfCopiesRequiredFocusNode = FocusNode();
  FocusNode kuliyaNoFocusNode = FocusNode();
  FocusNode attorneyGuidanceFocusNode = FocusNode();

  Helper(this.context, this.updateState, this.showProgressDialog, this.caseType,
      this.caseTypeName) {
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
                caseTypeName.toUpperCase(),
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
            decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(100)),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: caseStatus.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (caseStatus.indexOf(v!) != 0) {
                      caseSelectedStatusIndex = caseStatus.indexOf(v);
                      updateState();
                    }
                  },
                  iconEnabledColor: Utility.textBlackColor,
                  value: caseStatus[caseSelectedStatusIndex],
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
          caseSelectedStatusIndex != 0 ? casesBodyContainer() : Container(),
          ///////////////////////////////////////////////
          SizedBox(
            height: 20,
          ),
          caseSelectedStatusIndex != 0 ? requestButtonContainer() : Container(),
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
                      hintText: 'Abc  vs  Xyz'.toUpperCase(),
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
          caseType == 4
              ? Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Case No.',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10, left: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Utility.textBoxBorderColor,
                                        width: 1),
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
                                                .requestFocus(caseNoFocusNode);
                                          },
                                          onSubmitted: (value) {
                                            FocusScope.of(context).requestFocus(
                                                caseYearFocusNode);
                                          },
                                          focusNode: caseNoFocusNode,
                                          cursorColor: Utility.textBlackColor,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Case No.'.toUpperCase(),
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
                                          controller: caseNoController,
                                          onChanged: (value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Case year',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(right: 10, left: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Utility.textBoxBorderColor,
                                          width: 1),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    height: 55,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            readOnly: true,
                                            textInputAction:
                                                TextInputAction.next,
                                            onTap: () {
                                              _selectDate(
                                                  caseYearController, 'year');
                                            },
                                            onSubmitted: (value) {
                                              FocusScope.of(context)
                                                  .requestFocus(jugdeFocusNode);
                                            },
                                            focusNode: caseYearFocusNode,
                                            cursorColor: Utility.textBlackColor,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText:
                                                  'Case year'.toUpperCase(),
                                              hintStyle: TextStyle(
                                                fontSize: 15.0,
                                                color:
                                                    Utility.textBoxBorderColor,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              color: Utility.textBlackColor,
                                            ),
                                            maxLines: 1,
                                            controller: caseYearController,
                                            onChanged: (value) {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              : Container(),
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
                      // FocusScope.of(context).requestFocus(passwordNode);
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
          caseSelectedStatusIndex == 1
              ? Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Last Date of Hearing',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
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
                                readOnly: true,
                                textInputAction: TextInputAction.next,
                                onTap: () {
                                  _selectDate(
                                      lastHearingDateController, 'date');
                                },
                                onSubmitted: (value) {
                                  // FocusScope.of(context).requestFocus(passwordNode);
                                },
                                // focusNode: verificationNumberFocusNode,
                                cursorColor: Utility.textBlackColor,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Select the Last Date of Your Case'
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
                    ],
                  ),
                )
              : Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Date of Decision',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
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
                                readOnly: true,
                                textInputAction: TextInputAction.next,
                                onTap: () {
                                  _selectDate(decisionDateController, 'date');
                                },
                                onSubmitted: (value) {
                                  // FocusScope.of(context).requestFocus(passwordNode);
                                },
                                // focusNode: verificationNumberFocusNode,
                                cursorColor: Utility.textBlackColor,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      'Select the Date your case was Decided'
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
                                controller: decisionDateController,
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
          ///////////////////////////////////////////////
          caseSelectedStatusIndex == 1
              ? Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Next Date of Hearing',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
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
                                readOnly: true,
                                textInputAction: TextInputAction.next,
                                onTap: () {
                                  _selectDate(
                                      nextHearingDateController, 'date');
                                },
                                onSubmitted: (value) {
                                  // FocusScope.of(context).requestFocus(requiredDocumentFocusNode);
                                },
                                // focusNode: verificationNumberFocusNode,
                                cursorColor: Utility.textBlackColor,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Select Next Date of Your Case'
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
                    ],
                  ),
                )
              : Container(),
          ///////////////////////////////////////////////
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'What Copies are Required?',
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
                          .requestFocus(requiredDocumentFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(whichSideWeAreFocusNode);
                    },
                    focusNode: requiredDocumentFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: caseSelectedStatusIndex == 1
                          ? 'Complete File, Order Sheet, Copy of Stay Application etc'
                              .toUpperCase()
                          : 'Copy of complete File, order Sheet, stay application etc'
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
                    controller: requiredDocumentController,
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
              'Which party we are',
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
                          .requestFocus(whichSideWeAreFocusNode);
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(setOfCopiesRequiredFocusNode);
                    },
                    focusNode: whichSideWeAreFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Plaintiff No. 1, Defendant No. 5 etc'.toUpperCase(),
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
                    controller: whichSideWeAreController,
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
              'How many sets of copies',
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
                          .requestFocus(setOfCopiesRequiredFocusNode);
                    },
                    onSubmitted: (value) {
                      if (caseStatus == 2 && caseType != 4) {
                        FocusScope.of(context).requestFocus(kuliyaNoFocusNode);
                      } else {
                        FocusScope.of(context)
                            .requestFocus(attorneyGuidanceFocusNode);
                      }
                    },
                    focusNode: setOfCopiesRequiredFocusNode,
                    cursorColor: Utility.textBlackColor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '01, 02 etc'.toUpperCase(),
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
                    controller: setOfCopiesRequiredController,
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
          (caseSelectedStatusIndex == 2 && caseType != 4)
              ? Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kuliya No.',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
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
                                      .requestFocus(kuliyaNoFocusNode);
                                },
                                onSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(attorneyGuidanceFocusNode);
                                },
                                focusNode: kuliyaNoFocusNode,
                                cursorColor: Utility.textBlackColor,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      'If you don’t know Kuliya No. Don’t fill it'
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
                                controller: kuliyaNoController,
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                )
              : Container(),
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
        ],
      ),
    );
  }

  Widget requestButtonContainer() {
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
          'Generate request'.toUpperCase(),
          style: TextStyle(
              fontSize: 18,
              color: Utility.textWhiteColor,
              fontWeight: FontWeight.bold),
        ),
      ),
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
    } else if (caseType == 4 && caseNoController.text == '') {
      showToast('Please enter the Case No.');
    } else if (caseType == 4 && caseYearController.text == '') {
      showToast('Please enter the Case year');
    } else if (jugdeController.text == '') {
      showToast('Please enter the Judge');
    } else if (caseSelectedStatusIndex == 1 &&
        lastHearingDateController.text == '') {
      showToast('Please enter the Last hearing date');
    } else if (caseSelectedStatusIndex == 1 &&
        nextHearingDateController.text == '') {
      showToast('Please enter the Next hearing date');
    } else if (caseSelectedStatusIndex == 2 &&
        decisionDateController.text == '') {
      showToast('Please enter the Decision date');
    } else if (requiredDocumentController.text == '') {
      showToast('Please enter the Required documents');
    } else if (whichSideWeAreController.text == '') {
      showToast('Please enter the Which side we are');
    } else if (setOfCopiesRequiredController.text == '') {
      showToast('Please enter the Required set of copies');
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
                                RequestedAttestedCaseDetailScreen(
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

  void apiRequestCase() {
    FocusManager.instance.primaryFocus?.unfocus();
    showProgressDialog(true);
    print('in request case');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    params['case_type'] = caseType.toString();
    params['case_no'] = caseNoController.text;
    params['year'] = caseYearController.text;
    params['case_status'] = caseSelectedStatusIndex.toString();
    params['court_name'] = Utility.modelDistrict![selectedCourtIndex].name;
    params['title'] = titleController.text;
    params['judge_name'] = jugdeController.text;
    params['last_date_hearing'] = lastHearingDateController.text;
    params['next_hearing_date'] = nextHearingDateController.text;
    params['decision_date'] = decisionDateController.text;
    params['required_document'] = requiredDocumentController.text;
    params['from_which_side_we_are'] = whichSideWeAreController.text;
    params['set_of_copies_required'] = setOfCopiesRequiredController.text;
    params['comment_for_attorney'] = attorneyGuidanceController.text;

    print(REQUEST_CASE_URL);
    http
        .post(Uri.parse(REQUEST_CASE_URL), body: params, headers: headers)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      if (mappingResponse['success'] == true) {
        submittedCase = ModelCase.fromJson(mappingResponse['data']);
        updateState();
        clearFields();
        showRegistrationDialogBox(mappingResponse['message']);
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void clearFields() {
    titleController.clear();
    jugdeController.clear();
    lastHearingDateController.clear();
    nextHearingDateController.clear();
    caseNoController.clear();
    caseYearController.clear();
    decisionDateController.clear();
    requiredDocumentController.clear();
    whichSideWeAreController.clear();
    setOfCopiesRequiredController.clear();
    kuliyaNoController.clear();
    attorneyGuidanceController.clear();
  }
}
