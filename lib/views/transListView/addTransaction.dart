import 'package:expenser/db/models.dart';
import 'package:flutter/material.dart';

// Types of transactions
enum type { Credit, Debit }

class AddTransaction extends StatefulWidget {
  Function? onAdd = (t) {};
  AddTransaction({this.onAdd});
  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  var formKey = GlobalKey<FormState>();

  // Default type will be credit
  type Type = type.values[0];

  // Fields of the form
  List<Map<String, dynamic>> fields = [
    {
      "name": "name",
      "placeholder": "Name of your transaction",
      "type": TextInputType.text,
      "controller": new TextEditingController()
    },
    {
      "name": "amount",
      "placeholder": "Amount",
      "type": TextInputType.number,
      "controller": new TextEditingController()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Form(
            key: formKey,
            child: Column(
              children: [
                // Display form
                for (var field in fields)
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: TextFormField(
                      keyboardType: field["type"],
                      controller: field["controller"],
                      validator: (e) {
                        if (e!.isEmpty) {
                          return 'Fill this field !';
                        } else if (field["type"] == TextInputType.number &&
                            num.parse(e) <= 0) {
                          return 'Should be greater than 0';
                        }
                      },
                      decoration: InputDecoration(
                          hintText: field["placeholder"],
                          border: OutlineInputBorder()),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display the types of transactions to the user
                    for (var value in type.values)
                      Row(
                        children: [
                          Text(value.name),
                          Radio(
                            value: value,
                            groupValue: Type,
                            onChanged: (t) {
                              setState(() {
                                Type = t! as type;
                              });
                            },
                          )
                        ],
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            // Validate the form and create the transaction
                            if (formKey.currentState!.validate()) {
                              // Get inputs given by the user
                              var name=fields.firstWhere((element) => element["name"]=="name")["controller"].text;
                              var amount=fields.firstWhere((element) => element["name"]=="amount")["controller"].text;
                              
                              // Convert amount input given by user to integer
                              amount=num.parse(amount);

                              var value=amount;
                              if(Type==type.Debit){
                                value=0-amount;
                              }

                              // Create the transaction and apply inputs given by user to it
                              var trans=Transaction.createWithName(name);
                              trans.amount=amount;
                              trans.type=Type.name.toLowerCase();
                              trans.value=value;
                              
                              // Update the ui after adding
                              widget.onAdd!(trans);

                              // Close the dialog
                              Navigator.pop(context);
                            }
                          },
                          child: Text("Add")),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Close",style:TextStyle(color: Colors.white))),
                  ],
                ),
              ],
            )),
      ],
    );
  }
}
