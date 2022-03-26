import 'dart:convert';

class Transaction {
  int? id;
  num? value=0;
  num? amount=0;
  String? name;
  String? type;
  String? date;
  int? listId;

  Transaction({this.id,this.value,this.amount,this.name,this.date,this.type,this.listId});

  static Transaction createWithName(name){
    // This method creates a transaction

    DateTime time=new DateTime.now();
    Transaction trans= Transaction();

    trans.name=name;

    trans.id=new DateTime.now().microsecondsSinceEpoch;
    trans.date=time.toIso8601String();

    return trans;
  }

   @override
  Map<String,dynamic> toMap(){
    var map={
      "id":this.id,
      "name":this.name,
      "date":this.date,
      "amount":this.amount,
      "listId":this.listId,
      "type":this.type,
      "value":this.value
    };
    return map;
  }
}

class TransList {
  int? id;
  String? name;
  String? date;
  String? categories="[]";

  TransList({this.id,this.name,this.date,this.categories});

  static Future<TransList> createWithName(name)async{
    // This method creates a trans list

    DateTime time=new DateTime.now();
    TransList transList= TransList();

    transList.name=name;

    transList.id=new DateTime.now().microsecondsSinceEpoch;
    transList.date=time.toIso8601String();
    transList.categories="[]";

    return transList;
  }

  String getJson(){
    return jsonEncode({
      "id":this.id,
      "name":this.name,
      "date":this.date,
      "transactions":[],
    });
  }

  @override
  Map<String,dynamic> toMap(){
    var map={
      "id":this.id,
      "name":this.name,
      "date":this.date,
      "categories":this.categories
    };
    return map;
  }

  static TransList fromMap(Map<String,dynamic> map){
    var t=new TransList(id:map["id"],name: map["name"],date:map["date"],categories: map["categories"]);
    return t;
  }

  @override
  String toString(){
    return "transList id="+this.id!.toString();
  }
}

class Category{
  String? name;
  List<int>? transactions;

  Category({this.name,this.transactions});
}