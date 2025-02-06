import 'package:attorney/client/attestedServices/civilFamilyCriminalCase.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';

class ClientAttestedScreen extends StatefulWidget {
  @override
  _ClientAttestedScreenState createState() => _ClientAttestedScreenState();
}

class _ClientAttestedScreenState extends State<ClientAttestedScreen> {
  Helper? helper;
  bool _isLoading = false; // Replace ProgressHUD with a loading state

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
  TextEditingController phoneNumberController = TextEditingController();
  FocusNode phoneNumberFocusNode = FocusNode();
  // FirebaseAuth? auth;

  Helper(this.context, this.updateState, this.showProgressDialog) {
    // auth = FirebaseAuth.instance;
  }

  Widget statusBarContainer() {
    return Container(
      height: MediaQuery.of(context).padding.top,
      width: MediaQuery.of(context).size.width,
      color: Utility.textBlackColor,
    );
  }

  Widget safeBarContainer() {
    return Container(
      height: MediaQuery.of(context).padding.bottom,
      width: MediaQuery.of(context).size.width,
      color: Utility.textBlackColor,
    );
  }

  Widget actionBarContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Utility.textBlackColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )),
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
                'Attested Copy'.toUpperCase(),
                style: TextStyle(
                    color: Utility.whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'bold'),
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
            child: Text(
              'You should provide complete details of you case file in all categories of Attested Copy so that the Attorney can check your case file and provide you Attested Copy as soon as possible but if the details provided by you are incorrect and incomplete then it would be difficult for the Attorney to find out your file and to provide you attested copy fast.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CivilFamilyCriminalCaseScreen(1, 'Civil Cases')));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [new BoxShadow(
                //     color: Utility.shadowColor,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //     spreadRadius: 0.5
                // )],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Copy of Civil Cases',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.civil_case_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CivilFamilyCriminalCaseScreen(2, 'Family Cases')));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Copy of Family Cases',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor,
                          fontSize: 18,
                          fontFamily: 'medium'),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.family_case_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CivilFamilyCriminalCaseScreen(3, 'Criminal Cases')));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width / 2.1 - 15,
                    child: Text(
                      'Copy of Criminal Cases',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor, fontSize: 18),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.criminal_case_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CivilFamilyCriminalCaseScreen(
                          4, 'Copy of High Court Case')));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Utility.homeServicesColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 55,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width / 2.1 - 15,
                    child: Text(
                      'Copy of High Court Cases',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Utility.textBlackColor, fontSize: 18),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      Utility.high_court_case_image,
                      height: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
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
}
