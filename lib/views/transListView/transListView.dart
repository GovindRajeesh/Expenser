import 'dart:convert';
import 'dart:math';

import 'package:expenser/db/models.dart';
import 'package:expenser/db/tools.dart';
import 'package:expenser/tools/formattedNum.dart';
import 'package:expenser/tools/sumOfArray.dart';
import 'package:expenser/translist_bloc/translist_bloc.dart';
import 'package:expenser/views/transListView/categoryView.dart';
import 'package:expenser/views/transListView/transactionsView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:syncfusion_flutter_charts/charts.dart";


class TransListView extends StatefulWidget {
  final int? id;
  const TransListView({Key? key, this.id}) : super(key: key);

  @override
  State<TransListView> createState() => _TransListViewState();
}

class _TransListViewState extends State<TransListView> {
  bool loading = true;
  List<Transaction> transactions = [];
  List<dynamic> categories = [];
  num balance = 0;
  num? moneySpent;
  num? moneyEarned;
  TransList transList = TransList();
  var catExpenses = [];

  void getFromDb() async {
    var db = await getDb();
    var translist = await db.query(dbVars["tableNames"]["transList"],
        where: "id=?", whereArgs: [widget.id]);
    var list = await db.query(dbVars["tableNames"]["transaction"],
        where: "listId=?", whereArgs: [widget.id]);

    setState(() {
      transactions = list.map((l) {
        var transaction = Transaction(
          id: l["id"] as int,
          type: l["type"] as String,
          value: (l["value"] as num),
          amount: (l["amount"] as num),
          name: l["name"] as String,
          date: l["date"] as String,
          listId: l["listId"] as int,
        );
        return transaction;
      }).toList();

      if (translist.isEmpty) {
        Navigator.pop(context);
      } else {
        transList = translist.map((e) {
          return TransList.fromMap(e);
        }).toList()[0];
        categories = jsonDecode(transList.categories!);
        catExpenses = [];
        categories.forEach((category) {
          var trans = (category["transactions"] as List).map((e) {
            if (transactions.any((t) => t.id == e)) {
              return transactions.firstWhere((t) => t.id == e);
            } else {
              var t = Transaction.createWithName("");
              t.amount = 0;
              return t;
            }
          });

          var debittrans = trans.where((element) => element.type == "debit");

          catExpenses.add({
            "name": category["name"],
            "expense": sumOfArray(debittrans.map((e) => e.amount!).toList())
          });
        });
        loading = false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFromDb();
  }

  @override
  Widget build(BuildContext context) {
    balance = sumOfArray(transactions.map((e) => e.value!).toList());
    moneySpent = sumOfArray(transactions
        .where((e) => e.type == "debit")
        .toList()
        .map((e) => e.amount!)
        .toList());
    moneyEarned = sumOfArray(transactions
        .where((e) => e.type == "credit")
        .toList()
        .map((e) => e.amount!)
        .toList());
    return BlocListener<TranslistBloc, TranslistState>(
        listener: (_, state) async {
          getFromDb();
        },
        child: !loading
            ? DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(transList.name!),
                    bottom: TabBar(tabs: [
                      Tab(icon: Icon(Icons.home)),
                      Tab(icon: Icon(Icons.compare_arrows)),
                      Tab(icon: Icon(Icons.category)),
                    ]),
                  ),
                  body: TabBarView(children: [
                    ListView(
                      children: [
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Center(
                            child: SizedBox(
                          child: Card(
                            child: Column(
                              children: [
                                Container(
                                  child: Center(
                                      child: Text(
                                    "Balance",
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Color.fromARGB(255, 24, 24, 24)),
                                  )),
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("$balance",
                                      style: TextStyle(fontSize: 20)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                ),
                                NavigateToTab(
                                  tabIndex: 1,
                                  child: Container(
                                      width: double.infinity,
                                      color: Colors.blue,
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: Text(
                                              "View your transactions",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ))),
                                ),
                              ],
                            ),
                          ),
                          width: 300,
                        )),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Center(
                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(children: [
                              Wrap(children: [
                                Text(
                                  "Total debit:${moneySpent != null ? formattedNum(moneySpent) : 'calculating'}",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Text(
                                  "Total credit:${moneyEarned != null ? formattedNum(moneyEarned) : 'calculating'}",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ]),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                    "Total credit includes opening balance",
                                    style: TextStyle(fontSize: 16)),
                              )
                            ]),
                          )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        Center(
                            child: Text(
                          "Categories",
                          style: TextStyle(fontSize: 30),
                        )),
                        if (categories.length == 0)
                          NavigateToTab(
                              tabIndex: 2,
                              child: Center(
                                child: Text(
                                  "\nNo Categories found start adding",
                                  style: TextStyle(color: Colors.blue[200]),
                                ),
                              )),
                        if (categories.length > 0)
                          SfCircularChart(
                            title: ChartTitle(
                                text: "Expenses made in each category"),
                            legend: Legend(
                              isVisible: true,
                              borderWidth: 1,
                              borderColor: Colors.grey[300],
                            ),
                            series: [
                              PieSeries(
                                  dataSource: catExpenses,
                                  xValueMapper: (map, i) => map["name"],
                                  yValueMapper: (map, i) => (map["expense"] as num).toInt(),
                                  dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      textStyle: TextStyle(
                                          fontSize: 15, color: Colors.white)))
                            ],
                          ),
                      ],
                    ),
                    TransactionsView(
                      transactions: transactions,
                      afterAdd: (Transaction t) async {
                        if (t.type == "debit" && t.amount! > balance) {
                          var sbar = SnackBar(
                            content: Text("Insufficient balance !"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(sbar);
                        } else {
                          t.listId = widget.id;
                          var db = await getDb();
                          await db.insert(
                              dbVars["tableNames"]["transaction"], t.toMap());
                          await db.close();
                          setState(() {
                            transactions.add(t);
                          });
                        }
                      },
                      afterDelete: (id) {
                        setState(() {
                          transactions
                              .removeWhere((element) => element.id == id);
                        });

                        var ncategories = categories;
                        for (var i = 0;
                            i <
                                ncategories
                                    .where((element) =>
                                        (element["transactions"] as List)
                                            .contains(id))
                                    .toList()
                                    .length;
                            i++) {
                          var cat = ncategories[i];

                          (cat["transactions"] as List).remove(id);

                          ncategories[i] = cat;
                        }
                        setState(() {
                          categories = ncategories;
                          transList.categories = jsonEncode(categories);
                        });

                        BlocProvider.of<TranslistBloc>(context).add(
                            EditTranslistEvent(
                                id: transList.id, newOne: transList));
                      },
                    ),
                    CategoryView(
                      transactions: transactions,
                      categories: categories,
                      transList: transList,
                      afterAdd: (t) {
                        setState(() {
                          if (!(categories.any(
                              (element) => element["name"] == t["name"]))) {
                            categories.add(t);
                            transList.categories = jsonEncode(categories);
                            BlocProvider.of<TranslistBloc>(context).add(
                                EditTranslistEvent(
                                    id: widget.id, newOne: transList));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Category with same name exists")));
                          }
                        });
                      },
                      afterInsertToCat: (name, list) {
                        var categoryIndex = categories
                            .indexWhere((element) => element["name"] == name);
                        setState(() {
                          (categories[categoryIndex]["transactions"] as List)
                              .addAll(list);
                          transList.categories = jsonEncode(categories);
                          BlocProvider.of<TranslistBloc>(context).add(
                              EditTranslistEvent(
                                  id: widget.id, newOne: transList));
                        });
                      },
                    ),
                  ]),
                ))
            : Scaffold(
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                )),
              ));
  }
}

class NavigateToTab extends StatelessWidget {
  Widget? child;
  int? tabIndex;
  NavigateToTab({this.child, this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DefaultTabController.of(context)!.animateTo(tabIndex!);
      },
      child: child,
    );
  }
}
