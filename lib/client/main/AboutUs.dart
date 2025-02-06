import 'package:attorney/models/paymentMethod.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
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

  Helper(this.context, this.updateState, this.showProgressDialog);

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
                'about of app'.toUpperCase(),
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
        children: [
          Container(
            child: Text(
              'Based upon the idea that creative use of your smartphone and tablet can simplify your day-to-day work Attorney Official (SMC-Private) Limited company and this app is created. Whether you’re an iOS or Android user, this app is for lawyers and public that is built on a powerful infrastructure for your practice which will allow you to work remotely.'
              'Attorney Official App allows the customer all around the Pakistan to appoint attorney to get their work done through this app by filling the form and generating the request on Attorney Official App after selecting any of the service given below:-',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Attested Copy:',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'After providing complete details of your case file in all categories of Attested Copy and following the procedure as prescribed in Pending and In-Progress menu of the Attorney Official App, the appointed Attorney will prepare your Attested Copy and deliver or handover your copy to your doorstep through any of the Cash on Delivery courier services.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'semibold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          ///////////////////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Next Date of Hearing:',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'After providing complete details of your case file and following the procedure as prescribed in Pending and In-Progress menu of the Attorney Official App, the appointed Attorney after checking your case file will tell you the next date of hearing of your case.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'semibold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          ///////////////////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Interim Order/Last Order of Court:',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'After providing complete details of your case file and following the procedure as prescribed in Pending and In-Progress menu of the Attorney Official App, the appointed Attorney after checking your case file will send you pictures of interim order/order of court of your case.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'semibold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          ///////////////////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'File Your Case:',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'After providing complete details of your case file which you want to file before any court of law, sending file to the shipping address of the attorney and following the procedure as prescribed in Pending and In-Progress menu of the Attorney Official App, the appointed Attorney after receiving your case file will file your case before the court of law and inform you the name of judge and next date of hearing of your case.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'semibold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          ///////////////////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Filing any Application in Pending Case:',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'After providing complete details of your case file in which you want to file any type of your application, sending application file to the shipping address of the attorney and following the procedure as prescribed in Pending and In-Progress menu of the Attorney Official App, the appointed Attorney after receiving your any type of application file will submit your application file before the court where your case is pending.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'semibold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          ///////////////////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Summons/Notices:',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'After providing complete details of your case file and name of parties whom you want to summon or notice and following the procedure as prescribed in Pending and In-Progress menu of the Attorney Official App, the appointed Attorney after receiving front pages of your case in which it is clearly mentioned the name of parties whom you want to summon/notice will serve summon/notices through procedure of court.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'semibold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          ///////////////////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Newspaper Ad:',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'bold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'After providing complete details of your case file and name of parties against which you want to publish newspaper ad as per court order and following the procedure as prescribed in Pending and In-Progress menu of the Attorney Official App, the appointed Attorney after receiving front pages of your case in which it is clearly mentioned the name of parties and relevant details will publish your newspaper advertisement.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'semibold',
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          ///////////////////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
