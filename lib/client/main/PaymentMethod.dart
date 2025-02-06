import 'dart:convert';
import 'package:attorney/models/paymentMethod.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;

class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  Helper? helper;
  bool _isLoading = true; // Replace ProgressHUD with a loading state

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
                helper!.statusBarContainer(),
                helper!.actionBarContainer(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(0),
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

  Helper(this.context, this.updateState, this.showProgressDialog) {
    apiGetAllPaymentMethod();
  }

  List<ModelPaymentMethod>? paymentMethodList = null;

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
                'Payment methods'.toUpperCase(),
                style: TextStyle(
                    color: Utility.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: 40,
            child: null,
          ),
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

  Widget caseListView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemBuilder: caseListViewContainer,
        itemCount: paymentMethodList != null
            ? (paymentMethodList!.length > 0 ? paymentMethodList!.length : 0)
            : 0,
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget caseListViewContainer(BuildContext context, int index) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(
                ClipboardData(text: paymentMethodList![index].accountNo))
            .then((value) {
          showToast(
              'Account No. ${paymentMethodList![index].accountNo} copied to your clip board');
        });
      },
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          padding: EdgeInsets.all(15),
          // height: 100,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Container(
                child: Text(
                  'Bank Name: ${paymentMethodList![index].bankName}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  'Title: ${paymentMethodList![index].title}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  'Account No.: ${paymentMethodList![index].accountNo}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )),
    );
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

  void apiGetAllPaymentMethod() {
    Map<String, String> headers = Map();
    headers['Authorization'] = Utility.modelUser!.token;
    headers['Accept'] = 'application/json';

    print(GET_ALL_PAYMENTS_URL);
    http
        .post(Uri.parse(GET_ALL_PAYMENTS_URL), headers: headers)
        .then((response) async {
      showProgressDialog(false);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        if (mappingResponse['data'] != null) {
          paymentMethodList = (mappingResponse['data'] as List)
              .map((x) => ModelPaymentMethod.fromJson(x))
              .toList();
        } else {
          showToast(mappingResponse['message']);
        }
      } else {
        showToast(mappingResponse['message']);
      }
    });
  }

// void logout(){
//   preferences!.setString('mobile', '').then((isEmailSet) {
//     preferences!.setString('password', '').then((isPasswordSet) {
//       Utility.userLoggedIn = false;
//       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Splash()), (route) => false);
//       updateState();
//     });
//   });
// }
}
