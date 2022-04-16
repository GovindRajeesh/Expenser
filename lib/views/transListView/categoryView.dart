import 'dart:convert';

import 'package:expenser/db/models.dart';
import 'package:expenser/db/tools.dart';
import 'package:expenser/tools/sumOfArray.dart';
import 'package:expenser/translist_bloc/translist_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart' as sql;

class CategoryView extends StatefulWidget {
  List<Transaction>? transactions = [];
  List<dynamic>? categories = [];

  Function? afterAdd;
  Function? afterInsertToCat;

  TransList? transList;

  CategoryView({
    this.transactions,
    this.categories,
    this.afterAdd,
    this.afterInsertToCat,
    this.transList,
  });

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  TextStyle len0TextStyle = new TextStyle(
    fontSize: 20,
    color: Colors.grey,
  );
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var nameController = new TextEditingController();
  Map<String, List> selections = {};

  void onTransListUpdate() async {
    var transList = widget.transList;
    transList!.categories = jsonEncode(widget.categories);

    BlocProvider.of<TranslistBloc>(context)
        .add(EditTranslistEvent(id: transList.id, newOne: transList));
  }

  @override
  void initState() {
    super.initState();
    // Remove transactions that doesnt exist from categories
    for (var i = 0; i < widget.categories!.length; i++) {
      var cat = widget.categories![i];

      (cat["transactions"] as List).removeWhere((transid) {
        bool shouldBeDeleted =
            !(widget.transactions!.any((trans) => trans.id == transid));
        return shouldBeDeleted;
      });
    }
    widget.transList!.categories = jsonEncode(widget.categories);
    BlocProvider.of<TranslistBloc>(context).add(
        EditTranslistEvent(id: widget.transList!.id, newOne: widget.transList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (c) => AlertDialog(
                      title: Text("Add a category"),
                      content: Wrap(children: [
                        Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (e) {
                                    if (e!.isEmpty) {
                                      return "You have to fill this field!";
                                    } else if (widget.categories!.any(
                                        (element) => element["name"] == e)) {
                                      return "Category with same name exists!";
                                    }
                                  },
                                  controller: nameController,
                                  decoration: InputDecoration(
                                      label: Text("Enter a name"),
                                      border: OutlineInputBorder()),
                                )
                              ],
                            ))
                      ]),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                widget.afterAdd!({
                                  "name": nameController.text,
                                  "transactions": []
                                });
                                nameController.text = "";

                                Navigator.pop(context);
                              }
                            },
                            child: Text("Create")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Close")),
                      ],
                    ));
          },
        ),
        body: !widget.categories!.isEmpty
            ? ListView.builder(
                itemCount: widget.categories!.length,
                itemBuilder: (ctx, int index) {
                  var category = widget.categories![index];

                  var selectionsInCat = selections.containsKey(category["name"])
                      ? selections[category["name"]]
                      : [];
                  var catIndex = index;
                  return 
                    Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Center(
                            child: SizedBox(
                          width: 350,
                          child: Card(
                            child: Wrap(
                              children: [
                                Container(
                                  color: Colors.grey[100],
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(category["name"],
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black)),
                                  ),
                                ),
                                if ((category["transactions"]).isNotEmpty)
                                  for (var i in category["transactions"])
                                    CheckboxListTile(
                                        value: selections.containsKey(
                                                category["name"]) &&
                                            (selections[category["name"]]!)
                                                .contains(i),
                                        onChanged: (e) {
                                          setState(() {
                                            if (!selections.containsKey(
                                                category["name"])) {
                                              selections[category["name"]] = [];
                                            }
                                            if ((selections[category["name"]]!)
                                                .contains(i)) {
                                              (selections[category["name"]]
                                                      as List)
                                                  .remove(i);
                                            } else {
                                              (selections[category["name"]]
                                                      as List)
                                                  .add(i);
                                            }
                                          });
                                        },
                                        title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(widget.transactions!
                                                  .firstWhere((t) => t.id == i)
                                                  .name!),
                                              (widget.transactions!
                                                          .firstWhere(
                                                              (t) => t.id == i)
                                                          .type!) ==
                                                      "credit"
                                                  ? Icon(Icons.arrow_upward,
                                                      color: Colors.green)
                                                  : Icon(Icons.arrow_downward,
                                                      color: Colors.red),
                                            ])),
                                if ((category["transactions"] as List).isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                        "Start adding transactions to this category"),
                                  ),
                                Container(
                                  color: Colors.grey[100],
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.5),
                                    child: Wrap(children: [
                                      IconButton(
                                          tooltip:
                                              "Add an existing transaction into category ${category['name']}",
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        AddIntoCategory(
                                                          transactions: widget
                                                              .transactions!
                                                              .where((e) =>
                                                                  !((category["transactions"]
                                                                          as List)
                                                                      .contains(
                                                                          e.id)))
                                                              .toList(),
                                                          catName:
                                                              category["name"],
                                                          afterSubmit: (l) {
                                                            widget.afterInsertToCat!(
                                                                category[
                                                                    "name"],
                                                                l);
                                                          },
                                                        )));
                                          },
                                          icon: Icon(Icons.add,color:Colors.black)),
                                      IconButton(
                                          tooltip:
                                              "Remove the selected from the category ${category['name']}",
                                          onPressed: () {
                                            var selectionsOfThisCat = selections
                                                    .containsKey(
                                                        category["name"])
                                                ? selections[category["name"]]
                                                : [];

                                            var index = widget.categories!
                                                .indexWhere((e) =>
                                                    e["name"] ==
                                                    category["name"]);

                                            setState(() {
                                              (widget.categories![index]
                                                      ["transactions"] as List)
                                                  .removeWhere((t) =>
                                                      selectionsOfThisCat!
                                                          .contains(t));
                                              selections[category["name"]] = [];
                                            });
                                            onTransListUpdate();
                                          },
                                          icon: Icon(Icons.remove,color:Colors.black)),
                                      IconButton(
                                          tooltip:
                                              "Delete the category ${category['name']}",
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                      title: Text("Delete"),
                                                      content: Text(
                                                          "Are you sure that you want to delete the category ${category['name']}.This action will only delete the category and transactions wont be deleted"),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                if (selections
                                                                    .containsKey(
                                                                        category[
                                                                            "name"])) {
                                                                  selections.remove(
                                                                      category[
                                                                          "name"]);
                                                                }
                                                                widget
                                                                    .categories!
                                                                    .removeAt(
                                                                        catIndex);
                                                              });
                                                              onTransListUpdate();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text("Ok")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text("Cancel")),
                                                      ],
                                                    ));
                                          },
                                          icon: Icon(Icons.delete,color:Colors.black)),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )));
                })
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 100,
                      color: Colors.grey,
                    ),
                    Text("No categories found", style: len0TextStyle),
                    Text(
                      "Start adding categories",
                      style: len0TextStyle,
                    ),
                  ],
                ),
              ));
  }
}

class AddIntoCategory extends StatefulWidget {
  String? catName;
  List<Transaction>? transactions;
  Function? afterSubmit;
  AddIntoCategory({this.transactions, this.catName, this.afterSubmit});

  @override
  State<AddIntoCategory> createState() => _AddIntoCategoryState();
}

class _AddIntoCategoryState extends State<AddIntoCategory> {
  List<int> selected = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select items to add in ${widget.catName}"),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, index) {
          var transaction = widget.transactions![index];
          return Padding(
            padding: EdgeInsets.only(
                bottom: index == widget.transactions!.length - 1 ? 60 : 0),
            child: ListTile(
              leading: Icon(
                transaction.type == "credit"
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: transaction.type == "credit" ? Colors.green : Colors.red,
              ),
              trailing: Text("Amount: ${transaction.amount}"),
              tileColor: selected.contains(transaction.id!)
                  ? Colors.blue
                  : Colors.white,
              textColor: selected.contains(transaction.id!)
                  ? Colors.white
                  : Colors.black,
              title: Text(transaction.name!),
              onTap: () {
                setState(() {
                  if (!selected.contains(transaction.id)) {
                    selected.add(transaction.id!);
                  } else {
                    selected.remove(transaction.id!);
                  }
                });
              },
            ),
          );
        },
        itemCount: widget.transactions!.length,
      ),
      bottomSheet: SizedBox(
          height: 53,
          child: ListTile(
            textColor: Colors.white,
            tileColor: Colors.amber,
            title: Row(children: [Text("${selected.length} selected")]),
            trailing: IconButton(
              icon: Icon(Icons.save),
              color: Colors.white,
              onPressed: selected.length > 0
                  ? () {
                      if (widget.afterSubmit != null) {
                        widget.afterSubmit!(selected);
                      }
                      Navigator.pop(context);
                    }
                  : null,
            ),
          )),
    );
  }
}
