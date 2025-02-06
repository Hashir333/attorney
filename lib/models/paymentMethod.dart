
class ModelPaymentMethod{
  int id;
  String bankName;
  String title;
  String accountNo;



  ModelPaymentMethod.fromJson(Map json):
        id = json['id'] != null ? json['id'] : 0,
        bankName = json['bank_name'] != null ? json['bank_name'] : '',
        title = json['title'] != null ? json['title'] : '',
        accountNo = json['account_no'] != null ? json['account_no'] : '';

}