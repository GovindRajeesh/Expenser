import 'package:expenser/components/transactionView.dart';
import 'package:expenser/db/models.dart';
import 'package:expenser/db/tools.dart';
import 'package:expenser/tools/getDateText.dart';
import 'package:expenser/views/transListView/addTransaction.dart';
import 'package:flutter/material.dart';

class TransactionsView extends StatefulWidget {
  List<Transaction>? transactions = [];
  Function? afterDelete;
  Function? afterAdd;
  TransactionsView(
      {Key? key, this.transactions, this.afterDelete, this.afterAdd})
      : super(key: key);

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  @override
  Widget build(BuildContext context) {
    int balance = 0;
    TextStyle len0TextStyle = new TextStyle(
      fontSize: 20,
      color: Colors.grey,
    );
    Function deleteFunc(transaction) => () {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text("Delete"),
                    content:
                        Text("Do you want to delete ${transaction.name} ?"),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            (await getDb()).delete(
                                dbVars["tableNames"]["transaction"],
                                where: "id=?",
                                whereArgs: [transaction.id]);
                            Navigator.pop(context);
                            setState(() {
                              widget.afterDelete!(transaction.id);
                            });
                          },
                          child: Text("Ok")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"))
                    ],
                  ));
        };
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Center(child: Text("Add a transaction")),
                        content: AddTransaction(
                          onAdd: (t) async {
                            widget.afterAdd!(t);
                          },
                        ),
                      ));
            }),
        body: widget.transactions!.isNotEmpty
            ? ListView(
                children: <Widget>[
                  for (var transaction in widget.transactions!)
                    Padding(padding: EdgeInsets.only(bottom: 20),child: TransactionView(transaction: transaction,onDelete: deleteFunc(transaction),),),
                  Padding(padding: EdgeInsets.only(top: 100)),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      size: 100,
                      color: Colors.grey,
                    ),
                    Text("No transactions found", style: len0TextStyle),
                    Text(
                      "Start adding transactions",
                      style: len0TextStyle,
                    ),
                  ],
                ),
              ));
  }
}

class TransactionDisplay extends StatefulWidget {
  Transaction? transaction;
  TransactionDisplay({this.transaction});

  @override
  State<TransactionDisplay> createState() => _TransactionDisplayState();
}

class _TransactionDisplayState extends State<TransactionDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
