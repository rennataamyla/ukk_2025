import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/main.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding sudah diinisialisasi sebelum menjalankan kode async
  await Supabase.initialize( // Inisialisasi Supabase dengan URL dan kunci anon
    url: 'https://njefwoyeuwuyehoksium.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );
  runApp(MyApp()); // Menjalankan aplikasi utama
}

// Kelas StatefulWidget untuk halaman registrasi
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController(); 
  final TextEditingController _confirmPasswordController = TextEditingController(); 
  final TextEditingController _role = TextEditingController(); 
  bool _isLoading = false; 
  
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) { 
      final String username = _emailController.text;
      final String password = _confirmPasswordController.text;
      

      
      final user = await Supabase.instance.client.from('user').insert({
        'username': username,
        'password': password, 
      
      });

      // Navigasi ke Homepage jika berhasil
      if (user == null || user.isEmpty) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
      }
    }

    if (!_formKey.currentState!.validate()) return; // Jika form tidak valid, hentikan proses

    if (_passwordController.text != _confirmPasswordController.text) { // Periksa kesesuaian password
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi password tidak cocok')),
      );
      return;
    }

    setState(() {
      _isLoading = true; 
    });

    try {
    
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan verifikasi email Anda.')),
        );
        Navigator.pop(context); 
      } else if (response.user != null) {
        throw response.user!; // ⚠️ Logika ini tidak diperlukan, mungkin typo
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')), // Menampilkan pesan error jika gagal
      );
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Daftar'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Arahkan ke halaman login jika sudah punya akun
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginPage()),
                );
              },
              child: const Text('Sudah punya akun? Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}
