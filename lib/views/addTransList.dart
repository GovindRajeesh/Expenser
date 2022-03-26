import 'package:expenser/translist_bloc/translist_bloc.dart';
import 'package:expenser/db/models.dart';
import 'package:expenser/db/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sql.dart';

// Widget for creating a transaction list
class AddTransList extends StatefulWidget {
  const AddTransList({Key? key}) : super(key: key);

  @override
  State<AddTransList> createState() => _AddTransListState();
}

class _AddTransListState extends State<AddTransList> {
  var formKey = GlobalKey<FormState>();

  // Fields of the create form
  List<Map<String, dynamic>> fields = [
    {
      "name": "name",
      "placeholder": "Name of your transaction list",
      "type": TextInputType.text,
      "controller": new TextEditingController()
    },
    {
      "name": "firstBalance",
      "placeholder": "Opening balance",
      "type": TextInputType.number,
      "controller": new TextEditingController()
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a transaction list"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                TransList transList = await TransList.createWithName(fields
                    .firstWhere(
                        (field) => field["name"] == "name")["controller"]
                    .text);

                var amount = num.parse(fields
                    .firstWhere((field) => field["name"] == "firstBalance")[
                        "controller"]
                    .text);

                // Create opening balance transaction
                Transaction trans =
                    Transaction.createWithName("Opening balance");
                trans.amount = amount;
                trans.listId = transList.id!;
                trans.value = amount;
                trans.type = "credit";

                // Add the list to bloc and db
                BlocProvider.of<TranslistBloc>(context)
                    .add(AddTranslistEvent(transList: transList,ftrans:trans));

                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  for (var field in fields)
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: SizedBox(
                          width: 320,
                          child: TextFormField(
                            validator: (e) {
                              if (e!.isEmpty) {
                                return "Fill this field!";
                              }
                            },
                            controller: field["controller"],
                            keyboardType: field["type"],
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text(field["placeholder"])),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }
}
