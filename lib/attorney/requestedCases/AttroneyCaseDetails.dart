// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data';
import 'package:attorney/models/case.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;
// import 'package:photo_manager/photo_manager.dart';

class AttorneyCaseDetailScreen extends StatefulWidget {
  final int caseId;
  AttorneyCaseDetailScreen(this.caseId);

  @override
  _AttorneyCaseDetailScreenState createState() =>
      _AttorneyCaseDetailScreenState();
}

class _AttorneyCaseDetailScreenState extends State<AttorneyCaseDetailScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper =
          Helper(this.context, updateState, showProgressDialog, widget.caseId);
    }

    return Scaffold(
      backgroundColor: Utility.whiteColor,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading, // Pass loading state to modal progress HUD
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                helper!.statusBarContainer(),
                helper!.actionBarContainer(),
                Expanded(
                  child: ListView(
                    controller: helper!.scrollController,
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      helper!.caseDetails != null
                          ? helper!.bodyContainer()
                          : Container()
                    ],
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
  int caseId;
  ModelCase? caseDetails = null;
  ImagePicker _picker = ImagePicker();
  XFile? paymentScreenshot = null;
  List<XFile>? interimOrderScreenshot = [];
  XFile? filedCaseScreenshot = null;
  int disableUpdateButton = 1;
  int disableNextHearingDateButton = 1;
  int disableInterimOrderButton = 1;
  TextEditingController nextHearingDateDateController = TextEditingController();
  TextEditingController judgeNameController = TextEditingController();

  TextEditingController casePagesController = TextEditingController();
  FocusNode casePagesFocusNode = FocusNode();
  ScrollController scrollController = ScrollController();

  Helper(this.context, this.updateState, this.showProgressDialog, this.caseId) {
    apiGetCaseById();
    print(interimOrderScreenshot!.length);
  }

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
                'Case Details'.toUpperCase(),
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
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          caseDetails != null && caseDetails!.amountReceived != 0
              ? Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.only(bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey.shade300,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Amount Received by Admin: ${caseDetails!.amountReceived} Rs.',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'You will get after case compeletion: ${caseDetails!.attorneyAmountReceived} Rs.',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
          caseDetailsContainer(),
          SizedBox(
            height: 15,
          ),
          caseDetailsListView(),
          SizedBox(
            height: 30,
          ),
          (caseDetails!.case_type == '5' &&
                  caseDetails!
                          .caseDetailList[
                              caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'initial')
              ? Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Please select the next Hearing Date',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 10, left: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Utility.textBoxBorderColor,
                                          width: 1),
                                      color: Utility.whiteColor),
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  height: 55,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          readOnly: true,
                                          textInputAction: TextInputAction.next,
                                          onTap: () {
                                            _selectDate();
                                          },
                                          onSubmitted: (value) {},
                                          // focusNode: caseYearFocusNode,
                                          cursorColor: Utility.textBlackColor,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                'Please select the next Hearing Date'
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
                                          controller:
                                              nextHearingDateDateController,
                                          onChanged: (value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                disableNextHearingDateButton == 1
                                    ? InkWell(
                                        onTap: () {
                                          if (nextHearingDateDateController
                                                  .text !=
                                              '') {
                                            apiUpdateHearingDate();
                                          } else {
                                            showToast(
                                                'Please enter the Case Hearing Date');
                                          }
                                        },
                                        child: Container(
                                          // margin: EdgeInsets.symmetric(horizontal: 50),
                                          decoration: BoxDecoration(
                                            color: Utility.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          height: 55,
                                          width: 100,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Update'.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Utility.textWhiteColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          (caseDetails!.case_type == '6' &&
                  caseDetails!
                          .caseDetailList[
                              caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'initial')
              ? (interimOrderScreenshot!.length == 0
                  ? Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Please upload the clear picture of Interim Order',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              interimOrderScreenshot!.length == 0
                                  ? Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              print('interimOrderScreenshot');
                                              if (interimOrderScreenshot!
                                                      .length <
                                                  5) {
                                                getImages(
                                                    'interimOrderScreenshot');
                                              } else {
                                                showToast(
                                                    'you cannot upload more than 5 pictures');
                                              }
                                              updateState();
                                            },
                                            child: Container(
                                              height: 120,
                                              width: 120,
                                              color: Colors.grey.shade300,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add,
                                                    color:
                                                        Utility.textBlackColor,
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      'Upload Filed Case Image',
                                                      style: TextStyle(
                                                        color: Utility
                                                            .textBlackColor,
                                                        fontSize: 13,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              imageIdCardtFrontViewCardContainer(
                                                  interimOrderScreenshot),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      )),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Container(
                              height:
                                  interimOrderScreenshot!.length == 0 ? 0 : 170,
                              width: MediaQuery.of(context).size.width,
                              child: interimOrderImageListView()),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (disableInterimOrderButton == 1) {
                                    apiInterimOrder();
                                  }
                                },
                                child: Container(
                                  // margin: EdgeInsets.symmetric(horizontal: 50),
                                  decoration: BoxDecoration(
                                    color: Utility.primaryColor,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  height: 35,
                                  width: MediaQuery.of(context).size.width / 3,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'upload'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Utility.textWhiteColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )))
              : Container(),
          (caseDetails!.caseDetailList[caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'initial' &&
                  caseDetails!.case_type != '5' &&
                  caseDetails!.case_type != '6' &&
                  caseDetails!.case_type != '7' &&
                  caseDetails!.case_type != '9' &&
                  caseDetails!.case_type != '10')
              ? Container(
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter the No. of pages of case',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10, left: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Utility.textBoxBorderColor,
                                    width: 1),
                                color: Utility.whiteColor),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    textInputAction: TextInputAction.done,
                                    onTap: () {
                                      FocusScope.of(context)
                                          .requestFocus(casePagesFocusNode);
                                    },
                                    onSubmitted: (value) {
                                      // FocusScope.of(context).requestFocus(passwordFocusNode);
                                    },
                                    inputFormatters: [
                                      // LengthLimitingTextInputFormatter(11),
                                    ],
                                    focusNode: casePagesFocusNode,
                                    cursorColor: Utility.textBlackColor,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'No. of pages'.toUpperCase(),
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
                                    controller: casePagesController,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          disableUpdateButton == 1
                              ? InkWell(
                                  onTap: () {
                                    if (casePagesController.text.length > 0) {
                                      apiUpdateCasePages();
                                    } else {
                                      showToast(
                                          'Please enter the No. of pages');
                                    }
                                  },
                                  child: Container(
                                    // margin: EdgeInsets.symmetric(horizontal: 50),
                                    decoration: BoxDecoration(
                                      color: Utility.primaryColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    height: 55,
                                    width: 100,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Update'.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Utility.textWhiteColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
          (caseDetails!.caseDetailList[caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'initial' &&
                  caseDetails!.case_type == '9')
              ? Container(
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          apiUpdateFieCaseReceipt();
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Utility.primaryColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          height: 55,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Text(
                            'Mark as Summon has been processed'.toUpperCase(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Utility.textWhiteColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          (caseDetails!.caseDetailList[caseDetails!.caseDetailList.length - 1]
                      .type ==
                  'file_sent_to_attorney')
              ? Container(
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter the Judge Name',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10, left: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Utility.textBoxBorderColor,
                                    width: 1),
                                color: Utility.whiteColor),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    textInputAction: TextInputAction.done,
                                    onTap: () {
                                      // FocusScope.of(context).requestFocus(casePagesFocusNode);
                                    },
                                    onSubmitted: (value) {
                                      // FocusScope.of(context).requestFocus(passwordFocusNode);
                                    },
                                    inputFormatters: [
                                      // LengthLimitingTextInputFormatter(11),
                                    ],
                                    // focusNode: casePagesFocusNode,
                                    cursorColor: Utility.textBlackColor,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'Enter the Judge Name'.toUpperCase(),
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
                                    controller: judgeNameController,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          disableUpdateButton == 1
                              ? InkWell(
                                  onTap: () {
                                    if (judgeNameController.text.length == 0) {
                                      showToast('Please enter the Judge Name');
                                    } else if (nextHearingDateDateController
                                            .text ==
                                        '') {
                                      showToast(
                                          'Please enter the Next Hearing Date');
                                    } else {
                                      apiUpdateFiledCase();
                                    }
                                  },
                                  child: Container(
                                    // margin: EdgeInsets.symmetric(horizontal: 50),
                                    decoration: BoxDecoration(
                                      color: Utility.primaryColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    height: 55,
                                    width: 80,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Update'.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Utility.textWhiteColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter the Next Hearing Date',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10, left: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Utility.textBoxBorderColor,
                                    width: 1),
                                color: Utility.whiteColor),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    textInputAction: TextInputAction.done,
                                    onTap: () {
                                      _selectDate();
                                      // FocusScope.of(context).requestFocus(casePagesFocusNode);
                                    },
                                    onSubmitted: (value) {
                                      // FocusScope.of(context).requestFocus(passwordFocusNode);
                                    },
                                    inputFormatters: [
                                      // LengthLimitingTextInputFormatter(11),
                                    ],
                                    // focusNode: casePagesFocusNode,
                                    cursorColor: Utility.textBlackColor,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter the Next Hearing Date'
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
                                    controller: nextHearingDateDateController,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                )
              : Container(),
          (caseDetails!.caseDetailList[caseDetails!.caseDetailList.length - 1]
                      .type ==
                  'file_any_application_sent_to_attorney')
              ? InkWell(
                  onTap: () {
                    apiMarkFileReceivedFromCustomer();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    decoration: BoxDecoration(
                      color: Utility.primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 55,
                    // width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(
                      'Mark as File Received'.toUpperCase(),
                      style: TextStyle(
                          fontSize: 18,
                          color: Utility.textWhiteColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Container(),
          (caseDetails!.caseDetailList[caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'case_payment' ||
                  caseDetails!
                          .caseDetailList[
                              caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'attorney_case_update_of_hearing' ||
                  caseDetails!
                          .caseDetailList[
                              caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'attorney_case_update_interim_order' ||
                  caseDetails!
                          .caseDetailList[
                              caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'attorney_case_update_filed' ||
                  caseDetails!
                          .caseDetailList[
                              caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'attorney_case_update_summon' ||
                  caseDetails!
                          .caseDetailList[
                              caseDetails!.caseDetailList.length - 1]
                          .type ==
                      'filing_any_application_received_file_from_customer')
              ? InkWell(
                  onTap: () {
                    apiMarkCaseCompleted();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    decoration: BoxDecoration(
                      color: Utility.primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 55,
                    // width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(
                      'Mark Case as completed'.toUpperCase(),
                      style: TextStyle(
                          fontSize: 18,
                          color: Utility.textWhiteColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Container(),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget caseDetailsContainer() {
    return Container(
        padding: EdgeInsets.all(15),
        // height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          // borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Request #: ${caseDetails!.id}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'City: ${caseDetails!.court_name}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            caseDetails!.title != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'Case Title: ${caseDetails!.title}',
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
                    'Case Status: ${caseDetails!.status}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    'Case Type: ${caseDetails!.case_type_name}',
                    maxLines: 2,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    'Attorney: ${caseDetails!.attorneyDetails != null ? caseDetails!.attorneyDetails!.name : 'not assigned'}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            caseDetails!.judge_name != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'Judge: ${caseDetails!.judge_name}',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Container(),
            caseDetails!.parties_name != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'Parties Names: ${caseDetails!.parties_name}',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Container(),
            caseDetails!.no_of_defendant != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'No. of Defendents: ${caseDetails!.no_of_defendant}',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Container(),
            caseDetails!.last_date_hearing != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'Last Date of Hearing: ${caseDetails!.last_date_hearing}',
                          maxLines: 4,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Container(),
            caseDetails!.next_hearing_date != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'Next Date of Hearing: ${caseDetails!.next_hearing_date}',
                          maxLines: 4,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Container(),
            caseDetails!.next_date_hearing != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'Next Date of Hearing: ${caseDetails!.next_date_hearing}',
                          maxLines: 4,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Container(),
            caseDetails!.case_no != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Case No.: ${caseDetails!.case_no}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.year != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Year: ${caseDetails!.year}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.decision_date != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Decision date: ${caseDetails!.decision_date}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.required_document != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Required Documents: ${caseDetails!.required_document}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.from_which_side_we_are != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'From which party we are: ${caseDetails!.from_which_side_we_are}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.set_of_copies_required != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Set of copies required: ${caseDetails!.set_of_copies_required}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.kuliya_no != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Kuliya No.: ${caseDetails!.kuliya_no}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.parties_name != ''
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Parties Name: ${caseDetails!.parties_name}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            caseDetails!.comment_for_attorney != ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width - 60,
                        child: Text(
                          'Comments for Attorney: ${caseDetails!.comment_for_attorney}',
                          maxLines: 4,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ));
  }

  Widget caseDetailsListView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemBuilder: caseDetailsViewContainer,
        itemCount: caseDetails!.caseDetailList != null
            ? (caseDetails!.caseDetailList.length > 0
                ? caseDetails!.caseDetailList.length
                : 0)
            : 0,
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget caseDetailsViewContainer(BuildContext context, int index) {
    return Container(
        child: Column(
      children: [
        caseDetails!.caseDetailList[index].user_type == 'customer'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      caseDetails!.caseDetailList[index].caseDetailImage != null
                          ? InkWell(
                              onTap: () {
                                if (caseDetails!.caseDetailList[index]
                                        .caseDetailImage !=
                                    null) {
                                  showImageViewer(
                                      context,
                                      Image.network(caseDetails!
                                              .caseDetailList[index]
                                              .caseDetailImage!
                                              .url)
                                          .image,
                                      swipeDismissible: true);
                                }
                              },
                              child: Container(
                                height: 150,
                                child: CachedNetworkImage(
                                  imageUrl: caseDetails!.caseDetailList[index]
                                      .caseDetailImage!.url,
                                  placeholder: (context, url) => Container(
                                      child: Center(
                                          child:
                                              new CircularProgressIndicator())),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                          child: Center(
                                              child: new Icon(Icons.error))),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Utility.primaryColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          caseDetails!.caseDetailList[index].message,
                          style: TextStyle(
                              fontSize: 17, color: Utility.whiteColor),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Text(
                            caseDetails!.customer_id == Utility.modelUser!.id
                                ? Utility.modelUser!.name
                                : caseDetails!.customerDetails!.name),
                      ),
                      SizedBox(
                          height: caseDetails!
                                      .caseDetailList[index].caseDetailImage !=
                                  null
                              ? 5
                              : 0),
                      Container(
                        child:
                            Text(caseDetails!.caseDetailList[index].created_at),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      caseDetails!.caseDetailList[index]
                                  .caseDetailMultipleImages!.length >
                              1
                          ? Container(
                              height: 130,
                              width: MediaQuery.of(context).size.width - 30,
                              child: attorneyOrderImageListView(index))
                          : (caseDetails!
                                      .caseDetailList[index].caseDetailImage !=
                                  null
                              ? InkWell(
                                  onTap: () {
                                    if (caseDetails!.caseDetailList[index]
                                            .caseDetailImage !=
                                        null) {
                                      showImageViewer(
                                          context,
                                          Image.network(caseDetails!
                                                  .caseDetailList[index]
                                                  .caseDetailImage!
                                                  .url)
                                              .image,
                                          swipeDismissible: true);
                                    }
                                  },
                                  child: Container(
                                    height: 150,
                                    child: CachedNetworkImage(
                                      imageUrl: caseDetails!
                                          .caseDetailList[index]
                                          .caseDetailImage!
                                          .url,
                                      placeholder: (context, url) => Container(
                                          child: Center(
                                              child:
                                                  new CircularProgressIndicator())),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                              child: Center(
                                                  child:
                                                      new Icon(Icons.error))),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container()),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          caseDetails!.caseDetailList[index].message,
                          style: TextStyle(height: 1.5, fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Text(caseDetails!.caseDetailList[index].type ==
                                'attorney'
                            ? Utility.modelUser!.name
                            : (caseDetails!.attorneyDetails != null
                                ? caseDetails!.attorneyDetails!.name
                                : 'Admin')),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        child:
                            Text(caseDetails!.caseDetailList[index].created_at),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                ],
              ),
      ],
    ));
  }

  Widget imageIdCardtFrontViewCardContainer(image) {
    return Stack(
      children: [
        Container(
          height: 150,
          width: 100,
          child: Image.file(
            File(image!.path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            top: 5,
            left: 80,
            child: InkWell(
              onTap: () {
                image = null;
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

  Widget interimOrderImageListView() {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemBuilder: caseImageListViewContainer,
        itemCount: interimOrderScreenshot != null
            ? (interimOrderScreenshot!.length > 0
                ? interimOrderScreenshot!.length
                : 0)
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
            File(interimOrderScreenshot![index].path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            top: 5,
            left: 80,
            child: InkWell(
              onTap: () {
                interimOrderScreenshot!.removeAt(index);
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

  Widget attorneyOrderImageListView(caseDetailsIndex) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, x) =>
            attorneyListViewContainer(caseDetailsIndex, x),
        itemCount: caseDetails!.caseDetailList[caseDetailsIndex]
                    .caseDetailMultipleImages !=
                null
            ? (caseDetails!.caseDetailList[caseDetailsIndex]
                        .caseDetailMultipleImages!.length >
                    0
                ? caseDetails!.caseDetailList[caseDetailsIndex]
                    .caseDetailMultipleImages!.length
                : 0)
            : 0,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  Widget attorneyListViewContainer(i, x) {
    return InkWell(
      onTap: () {
        showImageViewer(
            context,
            Image.network(caseDetails!
                    .caseDetailList[i].caseDetailMultipleImages![x].url)
                .image,
            swipeDismissible: true);
      },
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            height: 100,
            width: 100,
            child: CachedNetworkImage(
              imageUrl: caseDetails!
                  .caseDetailList[i].caseDetailMultipleImages![x].url,
              placeholder: (context, url) => Container(
                  child: Center(child: new CircularProgressIndicator())),
              errorWidget: (context, url, error) =>
                  Container(child: Center(child: new Icon(Icons.error))),
              fit: BoxFit.cover,
            ),
          ),
          InkWell(
            onTap: () async {
              saveImageToGallery(
                  caseDetails!
                      .caseDetailList[i].caseDetailMultipleImages![x].url,
                  caseDetails!.caseDetailList[i].caseDetailMultipleImages![x].id
                      .toString());
            },
            child: Container(
              width: 100,
              child: Icon(Icons.download),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getImages(image) async {
    print(image);
    if (image == 'interimOrderScreenshot') {
      try {
        await _picker.pickMultiImage().then((value) {
          if (value != null) {
            interimOrderScreenshot!.addAll(value);
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
    } else {
      try {
        await _picker.pickImage(source: ImageSource.gallery).then((value) {
          if (value != null) {
            if (image == 'filedCaseScreenshot') {
              filedCaseScreenshot = value;
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
    }
    updateState();
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

  Future<Null> _selectDate() async {
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
        initialDatePickerMode: DatePickerMode.day,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000, 1),
        lastDate: DateTime.now().add(Duration(days: 4000)));

    if (picked != null) {
      var day = picked.day.toString() + "";
      var month = picked.month.toString() + "";
      // var year = picked.year.toString() + "";
      if (day.length == 1) {
        day = "0" + day;
      }
      if (month.length == 1) {
        month = "0" + month;
      }

      nextHearingDateDateController.text =
          DateFormat('dd MMMM yyyy').format(picked);
    }
  }

  void apiUploadInitialPayment() async {
    showProgressDialog(true);
    print('in attorney registration');
    Map<String, String> headers = Map();
    Map<String, dynamic> params = Map();

    headers['Accept'] = 'application/json';
    headers['Authorization'] = Utility.modelUser!.token;

    params['payment_type'] = 'initial';
    params['case_id'] = caseId.toString();
    params['payment_image'] = await MultipartFile.fromFile(
        paymentScreenshot!.path,
        filename: paymentScreenshot!.path.split('/').last);

    print(REGISTRATION_URL);
    print(params);

    FormData formData = FormData.fromMap(params);
    Dio dio = new Dio();
    dio
        .post(CASE_PAYMENT_URL,
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
        showToast(mappingResponse['message']);
        paymentScreenshot = null;
        apiGetCaseById();
        updateState();
      } else {
        if (response.statusCode != 200) {}
      }
    });
  }

  void apiUpdateFiledCase() async {
    disableUpdateButton = 2;
    updateState();
    showProgressDialog(true);
    print('in attorney registration');
    Map<String, String> headers = Map();
    Map<String, dynamic> params = Map();

    headers['Accept'] = 'application/json';
    headers['Authorization'] = Utility.modelUser!.token;

    params['payment_type'] = 'initial';
    params['case_id'] = caseId.toString();
    params['judge_name'] = judgeNameController.text;
    params['next_hearing_date'] = nextHearingDateDateController.text;
    params['filed_case_image'] = '';

    print(REGISTRATION_URL);
    print(params);

    FormData formData = FormData.fromMap(params);
    Dio dio = new Dio();
    dio
        .post(UPDATE_CASE_BY_ATTORNEY_URL,
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
        showToast(mappingResponse['message']);
        filedCaseScreenshot = null;
        apiGetCaseById();
        updateState();
      } else {
        if (response.statusCode != 200) {}
      }
    });
  }

  void apiUpdateFieCaseReceipt() async {
    disableUpdateButton = 2;
    updateState();
    showProgressDialog(true);
    print('in attorney registration');
    Map<String, String> headers = Map();
    Map<String, dynamic> params = Map();

    headers['Accept'] = 'application/json';
    headers['Authorization'] = Utility.modelUser!.token;

    params['case_id'] = caseId.toString();
    params['receipt_case_image'] = '';

    print(params);

    FormData formData = FormData.fromMap(params);
    Dio dio = new Dio();
    dio
        .post(UPDATE_CASE_BY_ATTORNEY_URL,
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
        showToast(mappingResponse['message']);
        filedCaseScreenshot = null;
        apiGetCaseById();
        updateState();
      } else {
        if (response.statusCode != 200) {
          Navigator.of(context).pop();
          disableUpdateButton = 2;
          updateState();
          showToast('something went wrong');
        }
      }
    });
  }

  void apiGetCaseById() {
    disableUpdateButton = 1;
    disableNextHearingDateButton = 1;
    disableInterimOrderButton = 1;
    updateState();
    print('in');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();

    print(ATTORNEY_CASE_BY_ID_URL);
    http
        .post(Uri.parse(ATTORNEY_CASE_BY_ID_URL),
            headers: headers, body: params)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      if (mappingResponse['success'] == true) {
        caseDetails = ModelCase.fromJson(mappingResponse['data']);
        Timer(Duration(seconds: 1), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          );
        });
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void apiUpdateCasePages() {
    disableUpdateButton = 2;
    updateState();
    showProgressDialog(true);
    print('in');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();
    params['pages'] = casePagesController.text.toString();

    print(UPDATE_CASE_BY_ATTORNEY_URL);
    http
        .post(Uri.parse(UPDATE_CASE_BY_ATTORNEY_URL),
            headers: headers, body: params)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        apiGetCaseById();
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void apiUpdateFilsedCase() {
    disableUpdateButton = 2;
    updateState();
    showProgressDialog(true);
    print('in');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();
    params['pages'] = casePagesController.text.toString();

    print(UPDATE_CASE_BY_ATTORNEY_URL);
    http
        .post(Uri.parse(UPDATE_CASE_BY_ATTORNEY_URL),
            headers: headers, body: params)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        apiGetCaseById();
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void apiUpdateHearingDate() {
    disableNextHearingDateButton = 2;
    updateState();
    showProgressDialog(true);
    print('in');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();
    params['hearing_date'] = nextHearingDateDateController.text.toString();

    print(UPDATE_CASE_BY_ATTORNEY_URL);
    http
        .post(Uri.parse(UPDATE_CASE_BY_ATTORNEY_URL),
            headers: headers, body: params)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        apiGetCaseById();
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void apiInterimOrder() async {
    disableInterimOrderButton = 2;
    updateState();
    showProgressDialog(true);
    print('in attorney registration');
    Map<String, String> headers = Map();
    Map<String, dynamic> params = Map();

    headers['Accept'] = 'application/json';
    headers['Authorization'] = Utility.modelUser!.token;

    params['case_id'] = caseId.toString();
    for (int i = 0; i < interimOrderScreenshot!.length; i++) {
      if (interimOrderScreenshot!.length > 5 && i == 5) {
        break;
      }
      params['interim_order_image[$i]'] = await MultipartFile.fromFile(
          interimOrderScreenshot![i].path,
          filename: interimOrderScreenshot![i].path.split('/').last);
    }

    print(UPDATE_CASE_BY_ATTORNEY_URL);
    print(params);

    FormData formData = FormData.fromMap(params);
    Dio dio = new Dio();
    dio
        .post(UPDATE_CASE_BY_ATTORNEY_URL,
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
        showToast(mappingResponse['message']);
        paymentScreenshot = null;
        apiGetCaseById();
        updateState();
      } else {
        if (response.statusCode != 200) {}
      }
    });
  }

  void apiMarkCaseCompleted() {
    showProgressDialog(true);

    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();

    print(CASE_COMPLETED_BY_ATTORNEY_URL);
    http
        .post(Uri.parse(CASE_COMPLETED_BY_ATTORNEY_URL),
            headers: headers, body: params)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        apiGetCaseById();
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void apiMarkFileReceivedFromCustomer() {
    showProgressDialog(true);

    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();

    print(RECEIVED_FILE_FROM_CUSTOMER_URL);
    http
        .post(Uri.parse(RECEIVED_FILE_FROM_CUSTOMER_URL),
            headers: headers, body: params)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        apiGetCaseById();
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

  void saveImageToGallery(String imageUrl, String imageId) async {
    /*showProgressDialog(true);

    try {
      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      Uint8List imageData = Uint8List.fromList(response.data);

      // Check and request permissions
      var permission = await PhotoManager.requestPermissionExtend();
      if (permission.isAuth) {
        // Save image to gallery with filename
        AssetEntity? result = await PhotoManager.editor.saveImage(
          imageData,
          filename: "$imageId.jpg", // 🔹 Required filename parameter added
        );

        if (result != null) {
          showToast('Image saved successfully');
        } else {
          showToast('Failed to save image');
        }
      } else {
        showToast('Permission denied to save images');
      }
    } catch (e) {
      showToast('Error: ${e.toString()}');
    }

    showProgressDialog(false);*/
  }
}
