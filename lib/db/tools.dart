import 'package:sqflite/sqflite.dart';

// Variables related to db
// like table names
// table names are stored here so that when we want to change the name we can do it from here
Map<String, dynamic> dbVars = {
  "fileName": "db.db",
  "tableNames": {
    "transList": "transLists", 
    "transaction": "transactions"
  }
};

Future<Database> getDb() async{
  Database db=await openDatabase(dbVars["fileName"],version: 1,onCreate: (db,i)async{
    await db.transaction((txn) async{
      var b=txn.batch();
       b.execute("CREATE TABLE ${dbVars['tableNames']['transList']}(id INTEGER,name TEXT,date TEXT,categories TEXT)");
       b.execute("CREATE TABLE ${dbVars['tableNames']['transaction']} (id INTEGER,name TEXT,value INTEGER,type TEXT,amount INTEGER,listId INTEGER,date STRING)");
       await b.commit();
    });
  });

  return db;
}