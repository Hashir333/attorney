import 'dart:convert';
import 'package:attorney/client/requestedCases/RequestAttestedCaseDetails.dart';
import 'package:attorney/client/requestedCases/RequestCaseDetails.dart';
import 'package:attorney/client/requestedCases/RequestNewPaperCaseDetails.dart';
import 'package:attorney/models/case.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;

class RequestedCasesMainScreen extends StatefulWidget {
  final int caseType;
  RequestedCasesMainScreen(this.caseType);

  @override
  _RequestedCasesMainScreenState createState() =>
      _RequestedCasesMainScreenState();
}

class _RequestedCasesMainScreenState extends State<RequestedCasesMainScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(
          this.context, updateState, showProgressDialog, widget.caseType);
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
  int selectedCaseType = 0;
  int caseType;

  Helper(
      this.context, this.updateState, this.showProgressDialog, this.caseType) {
    selectedCaseType = caseType;
    apiGetAllCases(caseType.toString());
  }

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
                'Requested Cases'.toUpperCase(),
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
              apiGetAllCases('1');
              selectedCaseType = 1;
              caseList = null;
              updateState();
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCaseType == 1
                      ? Utility.primaryColor
                      : Colors.grey.shade400),
              alignment: Alignment.center,
              height: 45,
              width: MediaQuery.of(context).size.width / 3.3,
              child: Text(
                'Pending',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Utility.whiteColor),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                showProgressDialog(true);
                apiGetAllCases('2');
                selectedCaseType = 2;
                caseList = null;
                updateState();
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
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
          ),
          SizedBox(
            width: 5,
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
              width: MediaQuery.of(context).size.width / 3.3,
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
                      child: Text(
                        'Case Type: ${caseList![index].case_type_name}',
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
                        print('Loop 1');
                        if (caseList![index].case_type == '1' ||
                            caseList![index].case_type == '2' ||
                            caseList![index].case_type == '3' ||
                            caseList![index].case_type == '4') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RequestedAttestedCaseDetailScreen(
                                          caseList![index].id))).then((value) {
                            caseList = null;
                            updateState();
                            selectedCaseType = caseType;
                            showProgressDialog(true);
                            apiGetAllCases(caseType.toString());
                          });
                        } else if (caseList![index].case_type == '10') {
                          print('Loop 2');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RequestedNewPaperCaseDetailScreen(
                                          caseList![index].id))).then((value) {
                            caseList = null;
                            updateState();
                            selectedCaseType = caseType;
                            showProgressDialog(true);
                            apiGetAllCases(caseType.toString());
                          });
                        } else {
                          print('Loop 3');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RequestedCaseDetailScreen(
                                          caseList![index].id))).then((value) {
                            caseList = null;
                            updateState();
                            selectedCaseType = caseType;
                            showProgressDialog(true);
                            apiGetAllCases(caseType.toString());
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

    // print(GET_ALL_CASE_URL + '/' + type);
    http
        .get(Uri.parse(GET_ALL_CASE_URL + '/' + type), headers: headers)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
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
}
