import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:ukk_2025/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjcm1nZnpwYnFodG5pdGZhaWxjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDg0MjgsImV4cCI6MjA1NDk4NDQyOH0.qsWBCon1ELTXPqB6MGns7PqOkOhCU3LgWTxpX0EcEik',
    url: 'https://acrmgfzpbqhtnitfailc.supabase.co',
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
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      // Snackbar untuk Field tidak boleh kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Field tidak boleh kosong'),
          backgroundColor: Colors.blue[200], // Warna background biru soft
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    try {
      final response = await supabase
          .from('user')
          .select('username, password')
          .eq('username', username)
          .single();
      if (response != null && response['password'] == password) {
        // Snackbar untuk Login berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login berhasil'),
            backgroundColor: Colors.blue[200], // Warna background hijau soft
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        // Snackbar untuk Username atau Password salah
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username atau Password anda salah!'),
            backgroundColor: Colors.red[200], // Warna background merah soft
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red[200], // Warna background merah soft
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('Login Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: Colors.blue[300],
            ),
            SizedBox(height: 20),

            // Username TextField
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Password TextField
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 24.0),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200], // Warna tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              ),
              child: Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            

            // Register button (optional)
            TextButton(
              onPressed: () {
                // Implement registrasi jika perlu
              },
              child: Text(
                'Belum punya akun? Daftar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[200],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
