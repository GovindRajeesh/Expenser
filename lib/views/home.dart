import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Center(
          child: Card(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Center(child:Text(
                  "Hello User !",
                  style: TextStyle(fontSize: 30),
                )),
                Center(child:Text(
                    "\nThis app is created to help you keep a track on your financial transactions",
                    style: TextStyle(fontSize: 17)),),
              ],
            ),
          )),
        )
      ],
    );
  }
}
