
class ModelUser{
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
  String account_title;
  String bank_account_title;
  String bank_account_no;
  String bank_name;
  String fcm_token;
  String created_at;
  String updated_at;
  String token;
  String address;
  String whatsapp;
  int paymentMethodCount;
  int pendingCaseCounts;
  int inProgressCaseCounts;
  int completedCaseCounts;



  ModelUser.fromJson(Map json):
        id = json['id'] != null ? json['id'] : 0,
        paymentMethodCount = json['paymentMethodCount'] != null ? json['paymentMethodCount'] : 0,
        pendingCaseCounts = json['pendingCaseCounts'] != null ? json['pendingCaseCounts'] : 0,
        inProgressCaseCounts = json['inProgressCaseCounts'] != null ? json['inProgressCaseCounts'] : 0,
        completedCaseCounts = json['completedCaseCounts'] != null ? json['completedCaseCounts'] : 0,
        name = json['name'] != null ? json['name'] : '',
        account_no = json['account_no'] != null ? json['account_no'] : '',
        account_title = json['account_title'] != null ? json['account_title'] : '',
        bank_account_title = json['bank_account_title'] != null ? json['bank_account_title'] : '',
        bank_account_no = json['bank_account_no'] != null ? json['bank_account_no'] : '',
        bank_name = json['bank_name'] != null ? json['bank_name'] : '',
        email = json['email'] != null ? json['email'] : '',
        user_type = json['user_type'] != null ? json['user_type'] : '',
        cnic = json['cnic'] != null ? json['cnic'] : '',
        mobile = json['mobile'] != null ? json['mobile'] : '',
        token = json['token'] != null ? json['token'] : '',
        courts = json['courts'] != null ? json['courts'] : '',
        address = json['address'] != null ? json['address'] : '',
        whatsapp = json['whatsapp'] != null ? json['whatsapp'] : '',
        shipping_address = json['shipping_address'] != null ? json['shipping_address'] : '',
        office_address = json['office_address'] != null ? json['office_address'] : '',
        fcm_token = json['fcm_token'] != null ? json['fcm_token'] : '',
        created_at = json['created_at'] != null ? json['created_at'] : '',
        updated_at = json['updated_at'] != null ? json['updated_at'] : '';

}