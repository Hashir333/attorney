class ModelSetting{

  List<ModelDistrict>? districtDetails;
  List<ModelCourt>? courtDetails;


  ModelSetting.fromJson(Map json):
        districtDetails = json['districts'] != null ? (json['districts'] as List).map((i) => ModelDistrict.fromJson(i)).toList() : [],
        courtDetails = json['courts'] != null ? (json['courts'] as List).map((i) => ModelCourt.fromJson(i)).toList() : [];

}

class ModelDistrict{
  int id;
  String name;

  ModelDistrict.fromJson(Map json):
        id = json['id'] != null? json['id'] : 0,
        name = json['name'] != null? json['name'] : '';
}

class ModelCourt{
  int id;
  String name;

  ModelCourt.fromJson(Map json):
        id = json['id'] != null? json['id'] : 0,
        name = json['name'] != null? json['name'] : '';
}