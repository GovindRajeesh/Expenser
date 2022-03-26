// Dashboard of the app

import 'package:expenser/views/home.dart';
import 'package:expenser/views/transListsWidget.dart';
import 'package:flutter/material.dart';

class DashBoard extends StatefulWidget {
  DashBoard({ Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  // Views of the dashboard
  List<Map<String,dynamic>> DashboardViews=[
  {
    "widget":Home(),
    "name":"Home",
    "icon":Icons.home
  },
  {
    "widget":TransListsWidget(),
    "name":"Lists",
    "icon":Icons.list
  },
  
];
  int currIndex=0;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text("Expenser"),),
      bottomNavigationBar: BottomNavigationBar(currentIndex: currIndex,onTap: (index)=>setState(() {
        currIndex=index;
      }), unselectedItemColor: Colors.black,selectedItemColor: Colors.blue,items: [
       for(var view in DashboardViews)
       BottomNavigationBarItem(icon: Icon(view["icon"]),label:view["name"])
      ]),
      body:DashboardViews[currIndex]["widget"],
    );
  }
}
