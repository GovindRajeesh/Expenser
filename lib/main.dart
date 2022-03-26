// Main file of this project

import 'dart:async';
import 'dart:io';

import 'package:expenser/translist_bloc/translist_bloc.dart';
import 'package:expenser/dashboard.dart';
import 'package:expenser/views/addTransList.dart';
import 'package:expenser/views/transListView/transListView.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TranslistBloc(),
      child: MaterialApp(
      title: 'Expenser',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Main(
        splash: false,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "addTransList":
            return PageTransition(
              type: PageTransitionType.rightToLeft,
              child: AddTransList(),
              settings: settings,
              duration: new Duration(milliseconds:200),
              reverseDuration: new Duration(milliseconds:200),
            );
            break;
          case "transListView":
          return PageTransition(
              type: PageTransitionType.bottomToTop,
              child: TransListView(id:settings.arguments! as int),
              settings: settings,
              duration: new Duration(milliseconds:200),
              reverseDuration: new Duration(milliseconds:200),
            );
            break;
          default:
        }
      },
    ),
    );
  }
}

class Main extends StatefulWidget {
  bool splash = true;
  Main({Key? key, splash}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  bool splash = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Timer(new Duration(seconds: 2), () async{
      // Get all data from db and put it in the transListBloc state
      BlocProvider.of<TranslistBloc>(context).add(InitTranslistEvent());
      // Stop the splash
      setState(() {
        splash = !splash;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return splash
        ? Scaffold(
            backgroundColor: splash ? Colors.orange : Colors.white,
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Expenser\n",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            )),
          )
        : DashBoard();
  }
}
