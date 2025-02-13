import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/login.dart';

void main() {
  Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjcm1nZnpwYnFodG5pdGZhaWxjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDg0MjgsImV4cCI6MjA1NDk4NDQyOH0.qsWBCon1ELTXPqB6MGns7PqOkOhCU3LgWTxpX0EcEik',
    url: 'https://acrmgfzpbqhtnitfailc.supabase.co');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.lightBlue[50],
      ),
      home: LoginPage(),
    );
  }
}

