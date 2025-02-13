import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:ukk_2025/main.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjcm1nZnpwYnFodG5pdGZhaWxjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDg0MjgsImV4cCI6MjA1NDk4NDQyOH0.qsWBCon1ELTXPqB6MGns7PqOkOhCU3LgWTxpX0EcEik',
    url:'https://acrmgfzpbqhtnitfailc.supabase.co'
  );
  runApp(MyApp()); 
}

class LoginPage extends StatefulWidget {
  @override
  _loginpageState createState() => _loginpageState(); 
}

class _loginpageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final SupabaseClient supabase =  Supabase.instance.client;
  
  Future<void> _login() async {
    final username = _usernameController.text; 
    final password = _passwordController.text; 

    if (username.isEmpty || password.isEmpty) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('harap mengisi semua field')), 
      );
      return;
    }
    try {
      
      final response = await supabase
        .from('user') 
        .select('username, password') 
        .eq('username', username) 
        .single(); 
      // ignore: unnecessary_null_comparison
      if (response != null && response['password'] == password) { 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('login berhasil')),
        );
        Navigator.pushReplacement( 
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username atau Password anda salah!')), 
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')), 
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('login page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController, 
              decoration: InputDecoration(
                labelText: 'Username', 
                border: OutlineInputBorder(), 
                prefixIcon: Icon(Icons.person, color: Colors.black), 
                filled: true,
                fillColor: Colors.white, 
              ),
            ),
             SizedBox(height: 16.0), 
             TextField(
              controller: _passwordController, 
              decoration: InputDecoration(
                labelText: 'Password', 
                border: OutlineInputBorder(), 
                prefixIcon: Icon(Icons.lock_person, color: Colors.black), 
                filled: true,
                fillColor: Colors.white, 
              ),
              obscureText: true, 
            ),
              SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800], 
              ),
              onPressed: _login, 
              child: Text('LOGIN', style: TextStyle(color: Colors.white)), 
            ),
            
          ],

        ),
      ),
    );
  }
}
 

