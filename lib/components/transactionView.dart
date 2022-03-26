import 'package:expenser/db/models.dart';
import 'package:flutter/material.dart';

import '../tools/getDateText.dart';

class TransactionView extends StatefulWidget {
  Transaction? transaction;
  Function? onDelete;
  TransactionView({@required this.transaction, this.onDelete});

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> {
  @override
  Widget build(BuildContext context) {
    var transaction = widget.transaction!;
    var onDelete = widget.onDelete;
    return Column(children: [
      Card(
          color: Colors.grey[30],
          child: Column(children: [
            Padding(
              child: Wrap(
                children: [
                  Wrap(
                    children: [
                      Text(
                        transaction.name!,
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("Type:"),
                      IconButton(
                          tooltip: transaction.type!.toUpperCase()[0] +
                              transaction.type!.substring(1),
                          onPressed: () {},
                          icon: Icon(
                            transaction.type == "credit"
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: transaction.type == "credit"
                                ? Colors.green
                                : Colors.red,
                          ))
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Amount:" + transaction.amount!.toString(),
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: Padding(
                child: Row(children: [
                  IconButton(
                      onPressed: onDelete != null
                          ? (onDelete as void Function())
                          : null,
                      icon: Icon(Icons.delete)),
                ]),
                padding: EdgeInsets.only(left: 10),
              ),
              color: Colors.grey[100],
            )
          ])),
      Padding(padding: EdgeInsets.only(left:10),child: Row(
        children: [Text("Transaction made on "+getDateText(transaction.date!),style: TextStyle(color: Colors.grey),)],
      ),)
    ]);
  }
}
