import 'dart:convert';
import 'package:attorney/models/payment.dart';
import 'package:attorney/models/paymentMethod.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final int caseId;
  final String message;
  final String amount;
  final String paymentType;
  PaymentScreen(this.caseId, this.message, this.amount, this.paymentType);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Helper helper;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    helper = Helper(context, updateState, showProgressDialog, widget.caseId,
        widget.message, widget.amount, widget.paymentType);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Scaffold(
        backgroundColor: Utility.whiteColor,
        body: ModalProgressHUD(
          inAsyncCall: _isLoading,
          child: Column(
            children: [
              helper.statusBarContainer(),
              helper.actionBarContainer(_isLoading),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: ClampingScrollPhysics(),
                  children: [helper.bodyContainer()],
                ),
              ),
              helper.safeBarContainer(),
            ],
          ),
        ),
      ),
    );
  }

  void updateState() {
    if (mounted) setState(() {});
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
  final BuildContext context;
  final Function updateState, showProgressDialog;
  final int caseId;
  final String message;
  final String amount;
  final String paymentType;

  TextEditingController caseNumController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  ModelPayment? paymentDetails;
  FocusNode mobileFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  Helper(this.context, this.updateState, this.showProgressDialog, this.caseId,
      this.message, this.amount, this.paymentType) {
    caseNumController.text = caseId.toString();
    amountController.text = amount;
  }

  Widget statusBarContainer() => Container(
        height: MediaQuery.of(context).padding.top,
        color: Utility.primaryColor,
      );

  Widget safeBarContainer() => Container(
        height: MediaQuery.of(context).padding.bottom,
        color: Utility.primaryColor,
      );

  Widget actionBarContainer(bool isLoading) => Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: 55,
        color: Utility.primaryColor,
        child: Row(
          children: [
            if (!isLoading)
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Utility.whiteColor),
                onPressed: () => Navigator.pop(context),
              ),
            Expanded(
              child: Center(
                child: Text(
                  'EasyPaisa Payment'.toUpperCase(),
                  style: TextStyle(
                      color: Utility.whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );

  Widget bodyContainer() => Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            buildTextField('Order#', caseNumController, readOnly: true),
            SizedBox(height: 15),
            buildTextField('Amount', amountController, readOnly: true),
            SizedBox(height: 15),
            buildTextField('Enter your EasyPaisa Mobile No.', mobileController,
                focusNode: mobileFocusNode, keyboardType: TextInputType.phone),
            SizedBox(height: 15),
            buildTextField('Email', emailController,
                focusNode: emailFocusNode,
                keyboardType: TextInputType.emailAddress),
            SizedBox(height: 40),
            payButtonContainer(),
          ],
        ),
      );

  Widget buildTextField(String label, TextEditingController controller,
      {bool readOnly = false,
      FocusNode? focusNode,
      TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Utility.textBoxBorderColor),
          ),
          height: 55,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget payButtonContainer() => InkWell(
        onTap: validations,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            color: Utility.primaryColor,
            borderRadius: BorderRadius.circular(100),
          ),
          height: 55,
          alignment: Alignment.center,
          child: Text('Pay'.toUpperCase(),
              style: TextStyle(
                  fontSize: 18,
                  color: Utility.textWhiteColor,
                  fontWeight: FontWeight.bold)),
        ),
      );

  void validations() {
    if (mobileController.text.isEmpty) {
      showToast('Please enter the Easypaisa Mobile No.');
    } else if (mobileController.text.length < 11) {
      showToast('Incorrect Mobile No.');
    } else {
      apiPay();
    }
  }

  void showToast(String msg) => Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Utility.toastBackgroundColor,
      textColor: Colors.white);

  void apiPay() {
    showProgressDialog(true);
    Map<String, String> headers = {
      'Authorization': Utility.modelUser!.token,
      'Accept': 'application/json'
    };
    Map<String, String> body = {
      'order_id': caseId.toString(),
      'amount': amountController.text,
      'mobile': mobileController.text,
      'email': emailController.text
    };

    http
        .post(Uri.parse(EASYPAISA_PAYMENT_URL), headers: headers, body: body)
        .then((response) {
      showProgressDialog(false);
      print('Response: ${response.body}');
      var mappingResponse = jsonDecode(response.body);
      showToast(mappingResponse['message']);
    }).catchError((error) {
      showProgressDialog(false);
      showToast("Payment failed. Please try again.");
    });
  }
}
