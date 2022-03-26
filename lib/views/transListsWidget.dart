import 'package:expenser/tools/getDateText.dart';
import 'package:expenser/translist_bloc/translist_bloc.dart';
import 'package:expenser/views/addTransList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Widget that shows all the transaction lists
class TransListsWidget extends StatefulWidget {
  const TransListsWidget({Key? key}) : super(key: key);

  @override
  State<TransListsWidget> createState() => _TransListsWidgetState();
}

class _TransListsWidgetState extends State<TransListsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            Navigator.pushNamed(context, "addTransList");
          },
        ),
        body: BlocBuilder<TranslistBloc, TranslistState>(
            builder: (context, state) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child:
                      Text("Transaction Lists", style: TextStyle(fontSize: 25)),
                ),
              ),
              for (var i in state.transLists!)
                ListTile(
                  onTap: (){
                    Navigator.pushNamed(context,"transListView",arguments:i.id);
                  },
                  leading: Icon(Icons.book),
                  title: Text(
                      i.name.toString()),
                  subtitle: Text("Created on " +
                      getDateText(i.date!)),
                  trailing: Wrap(children: <Widget>[
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  title: Text("Delete"),
                                  content: Text("Do you want to delete " +
                                      i.name.toString() +
                                      "?"),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          BlocProvider.of<TranslistBloc>(
                                                  context)
                                              .add(DeleteTranslistEvent(
                                                  id: i.id));
                                          Navigator.pop(context);
                                        },
                                        child: Text("OK")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                  ],
                                );
                              });
                        },
                        icon: Icon(Icons.delete)),
                  ]),
                ),
              if (state.transLists!.isEmpty)
                Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "No Transaction list have been created",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Press on ",
                                style: TextStyle(color: Colors.grey)),
                            Icon(
                              Icons.add,
                              color: Colors.grey,
                            ),
                            Text(" to create a transaction list",
                                style: TextStyle(color: Colors.grey))
                          ]),
                    ),
                  ],
                ),
            ],
          );
        }));
  }
}
