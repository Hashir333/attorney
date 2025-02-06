import 'dart:async';
import 'dart:convert';
import 'package:attorney/attorney/requestedCases/AttorneyCasesMain.dart';
import 'package:attorney/auth/login.dart';
import 'package:attorney/client/main/home.dart';
import 'package:attorney/models/setting.dart';
import 'package:attorney/models/user.dart';
import 'package:attorney/services/apis.dart';
import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
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
                Container(
                  height: MediaQuery.of(context).padding.top + 55,
                  width: MediaQuery.of(context).size.width,
                ),
                helper!.logoContainer(),
                Expanded(
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    children: [],
                  ),
                ),
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
  SharedPreferences? preferences;
  String mobile = '';
  String password = '';

  Helper(this.context, this.updateState, this.showProgressDialog) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });

    apiGetSettings();

    Timer(Duration(seconds: 3), () {
      checkLoggedIn();
    });
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

  Widget logoContainer() {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height / 1.5,
        width: MediaQuery.of(context).size.width / 1.5,
        child: Image.asset(Utility.logo),
      ),
    );
  }

  Future<void> checkLoggedIn() async {
    bool isUserLoggedIn = preferences!.getBool('isLoggedIn') ?? false;

    if (isUserLoggedIn == true) {
      mobile = preferences!.getString('mobile') ?? '';
      password = preferences!.getString('password') ?? '';
      print(mobile);

      if (mobile != '' && password != '') {
        apiUserLogin();
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      }
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    }
  }

  void apiUserLogin() {
    apiGetSettings();
    Map<String, String> header = Map();
    Map<String, String> params = Map();

    header['Accept'] = 'application/json';
    params['mobile'] = mobile;
    params['password'] = password;

    http
        .post(Uri.parse(LOGIN_URL), headers: header, body: params)
        .then((response) async {
      showProgressDialog(false);
      print(response.body);
      Map mappingResponse = jsonDecode(response.body);
      if (mappingResponse['success'] == true) {
        Utility.userLoggedIn = true;
        Utility.modelUser = ModelUser.fromJson(mappingResponse['data']);
        updateState();
        if (mappingResponse['data']['user_type'] == 'attorney') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => AttorneyCasesMainScreen()),
              (route) => false);
        } else if (mappingResponse['data']['user_type'] == 'customer' &&
            mappingResponse['data']['status'] == 2) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ClientHomeScreen()),
              (route) => false);
        }
      } else if (mappingResponse['success'] == false) {
        showToast(mappingResponse['message']);
      }
    });
  }

  void apiGetSettings() {
    print('i am in');
    Map<String, String> header = Map();
    // Map<String, String> params = Map();

    header['Accept'] = 'application/json';

    http
        .get(Uri.parse(GET_SETTINGS_URL), headers: header)
        .then((response) async {
      showProgressDialog(false);
      print('response');
      print(response);
      Map mappingResponse = jsonDecode(response.body);
      print(mappingResponse);
      if (mappingResponse['success'] == true) {
        Utility.modelDistrict = (mappingResponse['data']['districts'] as List)
            .map((x) => ModelDistrict.fromJson(x))
            .toList();
        Utility.modelCourt = (mappingResponse['data']['courts'] as List)
            .map((x) => ModelCourt.fromJson(x))
            .toList();

        updateState();
      } else if (mappingResponse['success'] == false) {}
    });
  }
}
