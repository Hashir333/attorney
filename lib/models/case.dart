import 'package:attorney/models/user.dart';

class ModelCase{
  int id;
  int customer_id;
  int attorney_id;
  String case_type;
  String case_type_name;
  String case_status;
  String court_name;
  String news_paper_name;
  String city;
  String title;
  String judge_name;
  String case_no;
  String year;
  String decision_date;
  String last_date_hearing;
  String last_hearing_date;
  String no_of_defendant;
  String next_date_hearing;
  String next_hearing_date;
  String required_document;
  String from_which_side_we_are;
  String set_of_copies_required;
  String kuliya_no;
  String parties_name;
  String comment_for_attorney;
  int amountReceived;
  int attorneyAmountReceived;
  String status;
  String created_at;
  String updated_at;
  ModelAttorneyDetails? attorneyDetails;
  ModelUser? customerDetails;
  List<ModelCaseDetails> caseDetailList;




  ModelCase.fromJson(Map json):
        id = json['id'] != null ? json['id'] : 0,
        customer_id = json['customer_id'] != null? json['customer_id'] : 0,
        attorney_id = json['attorney_id'] != null? json['attorney_id'] : 0,
        case_type = json['case_type'] != null? json['case_type'].toString() : '',
        case_type_name = json['case_type_name'] != null? json['case_type_name'].toString() : '',
        case_status = json['case_status'] != null? json['case_status'] : '',
        court_name = json['court_name'] != null? json['court_name'] : '',
        news_paper_name = json['news_paper_name'] != null? json['news_paper_name'] : '',
        city = json['city'] != null? json['city'] : '',
        title = json['title'] != null? json['title'] : '',
        judge_name = json['judge_name'] != null? json['judge_name'] : '',
        case_no = json['case_no'] != null? json['case_no'] : '',
        year = json['year'] != null? json['year'] : '',
        attorneyAmountReceived = json['attorneyAmountReceived'] != null? json['attorneyAmountReceived'].toInt() : 0,
        amountReceived = json['amountReceived'] != null? json['amountReceived'].toInt() : 0,
        decision_date = json['decision_date'] != null? json['decision_date'] : '',
        last_date_hearing = json['last_date_hearing'] != null? json['last_date_hearing'] : '',
        last_hearing_date = json['last_hearing_date'] != null? json['last_hearing_date'] : '',
        no_of_defendant = json['no_of_defendant'] != null? json['no_of_defendant'].toString() : '',
        next_date_hearing = json['next_date_hearing'] != null? json['next_date_hearing'] : '',
        next_hearing_date = json['next_hearing_date'] != null? json['next_hearing_date'] : '',
        required_document = json['required_document'] != null? json['required_document'] : '',
        from_which_side_we_are = json['from_which_side_we_are'] != null? json['from_which_side_we_are'] : '',
        set_of_copies_required = json['set_of_copies_required'] != null? json['set_of_copies_required'] : '',
        kuliya_no = json['kuliya_no'] != null? json['kuliya_no'] : '',
        parties_name = json['parties_name'] != null? json['parties_name'] : '',
        comment_for_attorney = json['comment_for_attorney'] != null? json['comment_for_attorney'] : '',
        status = json['status'] != null? json['status'] : '',
        created_at = json['created_at'] != null? json['created_at'] : '',
        updated_at = json['updated_at'] != null? json['updated_at'] : '',
        attorneyDetails = json['attorney_details'] != null ? ModelAttorneyDetails.fromJson(json['attorney_details']) : null,
        customerDetails = json['customer_details'] != null ? ModelUser.fromJson(json['customer_details']) : null,
        caseDetailList = json['customer_case_details'] != null ? (json['customer_case_details'] as List).map((i) => ModelCaseDetails.fromJson(i)).toList() : [];

}

class ModelAttorneyDetails{
  int id;
  String name;
  String user_type;
  String email;
  String cnic;
  String mobile;
  String shipping_address;
  String office_address;
  String courts;
  String account_no;
  String fcm_token;
  int status;
  String created_at;
  String updated_at;

  ModelAttorneyDetails.fromJson(Map json):
        id = json['id'] != null? json['id'] : 0,
        name = json['name'] != null? json['name'] : '',
        user_type = json['user_type'] != null? json['user_type'] : '',
        email = json['email'] != null? json['email'] : '',
        cnic = json['cnic'] != null? json['cnic'] : '',
        mobile = json['mobile'] != null? json['mobile'] : '',
        shipping_address = json['shipping_address'] != null? json['shipping_address'] : '',
        office_address = json['office_address'] != null? json['office_address'] : '',
        courts = json['courts'] != null? json['courts'] : '',
        account_no = json['account_no'] != null? json['account_no'] : '',
        fcm_token = json['fcm_token'] != null? json['fcm_token'] : '',
        status = json['status'] != null? json['status'] : 0,
        created_at = json['created_at'] != null? json['created_at'] : '',
        updated_at = json['updated_at'] != null? json['updated_at'] : '';
}

class ModelCaseDetails{
  int id;
  int case_id;
  int user_id;
  String user_type;
  String case_status;
  String amount;
  String type;
  String message;
  String created_at;
  String updated_at;
  ModelCaseDetailImages? caseDetailImage;
  List<ModelCaseDetailImagesList>? caseDetailMultipleImages;

  ModelCaseDetails.fromJson(Map json):
        id = json['id'] != null? json['id'] : 0,
        case_id = json['case_id'] != null? json['case_id'] : 0,
        user_id = json['user_id'] != null? json['user_id'] : 0,
        user_type = json['user_type'] != null? json['user_type'] : '',
        case_status = json['case_status'] != null? json['case_status'] : '',
        amount = json['amount'] != null? json['amount'] : '',
        type = json['type'] != null? json['type'] : '',
        message = json['message'] != null? json['message'] : '',
        created_at = json['created_at'] != null? json['created_at'] : '',
        updated_at = json['updated_at'] != null? json['updated_at'] : '',
        caseDetailImage = json['case_detail_image'] != null? ModelCaseDetailImages.fromJson(json['case_detail_image']) : null,
        caseDetailMultipleImages = json['case_detail_multiple_images'] != null ? (json['case_detail_multiple_images'] as List).map((i) => ModelCaseDetailImagesList.fromJson(i)).toList() : [];
}

class ModelCaseDetailImages{
  int id;
  String url;
  String type;

  ModelCaseDetailImages.fromJson(Map json):
        id = json['id'] != null? json['id'] : 0,
        url = json['url'] != null? json['url'] : '',
        type = json['type'] != null? json['type'] : '';
}

class ModelCaseDetailImagesList{
  int id;
  String url;
  String type;

  ModelCaseDetailImagesList.fromJson(Map json):
        id = json['id'] != null? json['id'] : 0,
        url = json['url'] != null? json['url'] : '',
        type = json['type'] != null? json['type'] : '';
}
