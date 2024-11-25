import 'package:flutter/material.dart';
import 'package:test_one/homepage.dart';
import 'package:test_one/sql_helper.dart';


Future main() async {
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    SQLHelper.db();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
