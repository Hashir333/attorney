// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:attorney/models/case.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;

class PendingApplicationRequestedCaseDetailScreen extends StatefulWidget {
  final int caseId;
  PendingApplicationRequestedCaseDetailScreen(this.caseId);

  @override
  _PendingApplicationRequestedCaseDetailScreenState createState() =>
      _PendingApplicationRequestedCaseDetailScreenState();
}

class _PendingApplicationRequestedCaseDetailScreenState
    extends State<PendingApplicationRequestedCaseDetailScreen> {
  Helper? helper;
  bool _isLoading = true; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper =
          Helper(this.context, updateState, showProgressDialog, widget.caseId);
    }

    return Scaffold(
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
  int disableImageUploadButton = 1;
  int disableNotifyAttorneyButton = 1;
  ScrollController scrollController = ScrollController();

  Helper(this.context, this.updateState, this.showProgressDialog, this.caseId) {
    apiGetCaseById();
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
          caseDetailsContainer(),
          SizedBox(
            height: 15,
          ),
          caseDetailsListView(),
          SizedBox(
            height: 30,
          ),
          //caseDetails!.caseDetailList[caseDetails!.caseDetailList.length -1].type == 'attorney_assigned' )?
          (caseDetails!.caseDetailList[caseDetails!.caseDetailList.length - 1]
                      .type ==
                  'request')
              ? (paymentScreenshot == null
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                                      'Upload Image',
                                      style: TextStyle(
                                        color: Utility.textBlackColor,
                                        fontSize: 13,
                                      ),
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
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              imageIdCardtFrontViewCardContainer(),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (disableImageUploadButton == 1) {
                                    apiUploadInitialPayment('initial');
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
          SizedBox(
            height: 30,
          ),
          (caseDetails!.caseDetailList[caseDetails!.caseDetailList.length - 1]
                      .type ==
                  'attorney_assigned')
              ? InkWell(
                  onTap: () {
                    if (disableNotifyAttorneyButton == 1) {
                      apiNotifyAttorneyForFileCaseSent();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Utility.primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    // height: 55,
                    // width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(
                      'Notify Attorney \n File couriered '.toUpperCase(),
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
                  'initial')
              ? InkWell(
                  onTap: () {
                    if (disableNotifyAttorneyButton == 1) {
                      apiNotifyAttorneyForFileCaseSent();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Utility.primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    // height: 55,
                    // width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(
                      'Notify Attorney \n File couriered '.toUpperCase(),
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
    return InkWell(
        onTap: () {},
        child: Container(
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
                      child: Text(
                        'Case Title: ${caseDetails!.title}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      child: Text(
                        'Case Status: ${caseDetails!.case_status}',
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
                        'Case Type: ${caseDetails!.case_type}',
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
                        'Attorney: ${caseDetails!.attorneyDetails != null ? caseDetails!.attorneyDetails!.name : 'not assigned'}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    caseDetails!.judge_name != ''
                        ? Container(
                            child: Text(
                              'Judge: ${caseDetails!.judge_name}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                caseDetails!.case_no != ''
                    ? Container(
                        margin: EdgeInsets.only(bottom: 10),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Case No.: ${caseDetails!.case_no}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                caseDetails!.last_date_hearing != ''
                    ? Container(
                        margin: EdgeInsets.only(bottom: 10),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Last hearing date: ${caseDetails!.last_date_hearing}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                caseDetails!.next_hearing_date != ''
                    ? Container(
                        margin: EdgeInsets.only(bottom: 10),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Next hearing date: ${caseDetails!.next_hearing_date}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                caseDetails!.comment_for_attorney != ''
                    ? Container(
                        margin: EdgeInsets.only(bottom: 10),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Comment for Attorney: ${caseDetails!.comment_for_attorney}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
              ],
            )));
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
        // padding: EdgeInsets.all(),
        child: Column(
      children: [
        caseDetails!.caseDetailList[index].user_type == 'customer'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          caseDetails!.caseDetailList[index].message,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Text(
                            caseDetails!.customer_id == Utility.modelUser!.id
                                ? Utility.modelUser!.name
                                : ''),
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
                        height: 10,
                      ),
                    ],
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Utility.primaryColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          caseDetails!.caseDetailList[index].message,
                          style: TextStyle(
                              height: 1.5,
                              fontSize: 17,
                              color: Utility.whiteColor),
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
                        height: 10,
                      ),
                    ],
                  )
                ],
              ),
      ],
    ));
  }

  Widget imageIdCardtFrontViewCardContainer() {
    return Stack(
      children: [
        Container(
          height: 150,
          width: 100,
          child: Image.file(
            File(paymentScreenshot!.path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            top: 5,
            left: 80,
            child: InkWell(
              onTap: () {
                paymentScreenshot = null;
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

  Future<void> getImages() async {
    try {
      await _picker.pickImage(source: ImageSource.gallery).then((value) {
        if (value != null) {
          paymentScreenshot = value;
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

  void apiUploadInitialPayment(type) async {
    disableImageUploadButton = 2;
    updateState();
    showProgressDialog(true);
    print('in attorney registration');
    Map<String, String> headers = Map();
    Map<String, dynamic> params = Map();

    headers['Accept'] = 'application/json';
    headers['Authorization'] = Utility.modelUser!.token;

    if (type == 'initial') {
      params['payment_type'] = 'initial';
    } else {
      params['payment_type'] = 'case_payment';
    }

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

  void apiGetCaseById() {
    disableImageUploadButton = 1;
    disableNotifyAttorneyButton = 1;
    updateState();
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();

    print(CASE_BY_ID_URL);
    http
        .post(Uri.parse(CASE_BY_ID_URL), headers: headers, body: params)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
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

  void apiNotifyAttorneyForFileCaseSent() {
    disableNotifyAttorneyButton = 2;
    updateState();
    showProgressDialog(true);
    print('in');
    Map<String, String> headers = Map();
    Map<String, String> params = Map();

    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';
    params['case_id'] = caseId.toString();

    print(ATTORNEY_NOTIFIED_BY_CUSTOMER_URL);
    http
        .post(Uri.parse(ATTORNEY_NOTIFIED_BY_CUSTOMER_URL),
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
}
