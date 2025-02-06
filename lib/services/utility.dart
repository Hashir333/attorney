import 'package:attorney/models/setting.dart';
import 'package:attorney/models/user.dart';
import 'package:flutter/material.dart';

class Utility {
  static Color progressHudColor = Colors.black;
  static Color mainTextColor = Color(0xFF800000);
  static Color mainBottomBarColor = Color(0xFF0074E3);
  static Color toastBackgroundColor = Color(0xFF012928);
  static Color actionBarColor = Color(0xFFB79965);
  static Color statusBarColor = Color(0xFFB79965);
  static Color safeBarColor = Color(0xFFB79965);
  static Color whiteColor = Color(0xFFFFFFFF);
  static Color textBlackColor = Color(0xFF000000);
  static Color textWhiteColor = Color(0xFFFFFFFF);
  static Color selectedColor = Color(0xFF0063C2);
  static Color shadowColor = Colors.grey.shade600;
  static Color mainTopBarTextColor = Color(0xFFB79968);
  static Color phonebookCardTextColor = Color(0xFF9FBDBF);
  static Color primaryColor = Colors.black;
  static Color secondaryColor = Color(0xFFCA9F38);
  static Color textBoxBorderColor = Colors.grey.shade500;
  static Color textHintColor = Color(0xFF8F8E98);
  static Color homeServicesColor = Color(0xFFE4E4E4);

  static String api_verification_key = "";
  static String app_name = "Attorney";

  static bool? userLoggedIn;
  static String? userToken;
  static ModelUser? modelUser;
  static List<ModelDistrict>? modelDistrict;
  static List<ModelCourt>? modelCourt;
  static int? cartQuantity = 0;
  static double? cartAmount = 0;
  static double? deliveryCharges = 50;

  static String logo = 'assets/icons/logo2.png';
  static String background = 'assets/images/background.png';
  static String login_background = 'assets/images/login_background.png';
  static String attested_image = 'assets/icons/attested.png';
  static String next_date_image = 'assets/icons/next-date.png';
  static String interim_order_image = 'assets/icons/interim-order.png';
  static String case_filing_image = 'assets/icons/case-filing.png';
  static String application_filing_image =
      'assets/icons/application-filing.png';
  static String summon_notices_image = 'assets/icons/summon-notices.png';
  static String newspaper_ad_image = 'assets/icons/newspaper-ad.png';
  static String civil_case_image = 'assets/icons/civil-case.png';
  static String family_case_image = 'assets/icons/family-case.png';
  static String criminal_case_image = 'assets/icons/criminal-case.png';
  static String high_court_case_image = 'assets/icons/high-court.png';

  /////////////////////////////////////////////////////////////////////////////////////
  static String verificationId = '';
  /////////////////////////////////////////////////////////////////////////////////////

  static List<String> courtList = [
    'Select Court',
    'HIGH COURT',
    'DISTRICT AND SESSION JUDGE',
    'SENIOR CIVIL JUDGE',
    'SPECIAL ANTI NARCOTICS FORCE COURT',
    'SPEICAL ANTI TERRORISM COURT',
    'SPECIAL CONSUMER COURT',
    'SPECIAL ANTI CORRUPTION COURT',
    'COURT OF MEMBER BOARD OF REVENUE',
    'COURT OF COMMISISONER REVENUE',
    'COURT OF ADDITIONAL COMMISSIONER REVENUE',
    'COURT OF ADDITIONAL DISTRICT COLLECTOR REVENUE',
    'COURT OF ASSISTANT COMMISSIONER',
    'COURT OF TEHSILDAR',
  ];

  static List<String> citiesList = [
    'Select Court',
    'Rawalpindi',
  ];

  static List<String> lawyerCitiesList = [
    'Station of Practice',
    'Rawalpindi',
  ];

  static List<String> cities2List = [
    'Select Tehsil/City',
    'Rawalpindi',
  ];

  static List<String> paymentMethods = [
    'Add Account No.',
    'Jazz Cash',
    'Easy Paisa',
    'Other Account',
  ];
}
