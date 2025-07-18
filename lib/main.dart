import 'package:flutter/material.dart';
import 'pages/dashboard_teacher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeakUp TSN',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
       home: DashboardTeacher(),
    );
  }
}
