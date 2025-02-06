
class ModelPayment{
  int id;
  String case_id;
  String transaction_id;
  String transaction_date_time;
  String response_code;
  String amount;
  String response_desc;
  String created_at;
  String updated_at;



  ModelPayment.fromJson(Map json):
        id = json['id'] != null ? json['id'] : 0,
        case_id = json['case_id'] != null ? json['case_id'] : '',
        transaction_id = json['transaction_id'] != null ? json['transaction_id'] : 0,
        transaction_date_time = json['transaction_date_time'] != null ? json['transaction_date_time'] : '',
        response_code = json['response_code'] != null ? json['response_code'] : '',
        response_desc = json['response_desc'] != null ? json['response_desc'] : '',
        amount = json['amount'] != null ? json['amount'] : '',

        created_at = json['created_at'] != null ? json['created_at'] : '',
        updated_at = json['updated_at'] != null ? json['updated_at'] : '';

}