import 'package:bloc/bloc.dart';
import 'package:expenser/db/models.dart';
import 'package:expenser/db/tools.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart' as s;

part 'translist_event.dart';
part 'translist_state.dart';

class TranslistBloc extends Bloc<TranslistEvent, TranslistState> {
  // Handle initialisation of bloc
  TranslistBloc() : super(TranslistInitial()) {
    on<InitTranslistEvent>((event, emit) async {
      // Our db
      var db = await getDb();

      // Retrieve data from db
      var list = (await db.query(dbVars["tableNames"]["transList"],orderBy: "id DESC")).map((e) {
        return TransList.fromMap(e);
      });
      await db.close();

      // Update bloc state
      return emit(TranslistState(transLists: list.toList()));
    });
    // Handle create transaction list
    on<AddTranslistEvent>((event, emit) async {
      var transLists = state.transLists;
      transLists=[event.transList!]+transLists!;
      getDb().then((db)async {
        // Insert into db
        await db.insert(
            dbVars["tableNames"]["transList"],
            event.transList!.toMap(),
            conflictAlgorithm: s.ConflictAlgorithm.replace);

        await db.insert('transactions', event.ftrans!.toMap(),conflictAlgorithm: s.ConflictAlgorithm.replace);

        await db.close();
      });

      // Update the bloc state
      return emit(TranslistState(transLists: transLists));
    });

    on<DeleteTranslistEvent>((event, emit) async{
      var transLists = state.transLists;

      var db=await getDb();
      await db.delete(dbVars["tableNames"]["transList"],where: "id=?",whereArgs:[event.id]);
      await db.delete(dbVars["tableNames"]["transaction"],where: "listId=?",whereArgs:[event.id]);
      await db.close();

      transLists!.removeWhere((l) => l.id == event.id);
      return emit(TranslistState(transLists: transLists));
    });
    // Handle edit of transaction list
    on<EditTranslistEvent>((event,emit)async{
      var transLists=state.transLists;

      var index=transLists!.indexWhere((element) =>element.id==event.id);

      transLists[index]=event.newOne!;

      var db=await getDb();
      await db.update(dbVars["tableNames"]["transList"],transLists[index].toMap(),where: "id=?",whereArgs: [event.id]);
      await db.close();

      return emit(TranslistState(transLists: transLists));
    });
  }
}
