import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:ukk_2025/main.dart';
import 'package:ukk_2025/user/insert.dart';  // Ganti dengan halaman tujuan setelah registrasi

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding sudah diinisialisasi sebelum menjalankan kode async
  await Supabase.initialize( // Inisialisasi Supabase dengan URL dan kunci anon
    url: 'https://njefwoyeuwuyehoksium.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );
  runApp(MyApp()); // Menjalankan aplikasi utama
}

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
 final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi formulir
  final TextEditingController _emailController = TextEditingController(); // Controller untuk input email
  final TextEditingController _passwordController = TextEditingController(); // Controller untuk input password
  final TextEditingController _confirmPasswordController = TextEditingController(); // Controller untuk konfirmasi password
 // Controller untuk input role
  bool _isLoading = false; // Variabel untuk menampilkan indikator loading

  // Fungsi untuk registrasi pengguna
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) { // Validasi input form
      final String username = _emailController.text;
      final String password = _confirmPasswordController.text;
    

      // Menyimpan data pengguna ke dalam tabel Supabase (seharusnya tidak menyimpan password secara langsung)
      final user = await Supabase.instance.client.from('user').insert({
        'username': username,
        'password': password, // ⚠️ Harus dienkripsi sebelum disimpan!
      
      });

      // Navigasi ke Homepage jika berhasil
      if (user == null || user.isEmpty) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => InsertUser()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => InsertUser()));
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
      _isLoading = true; // Menampilkan indikator loading
    });

    try {
      // Mendaftarkan pengguna menggunakan Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) { // Jika registrasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan verifikasi email Anda.')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else if (response.user != null) {
        throw response.user!; // ⚠️ Logika ini tidak diperlukan, mungkin typo
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')), // Menampilkan pesan error jika gagal
      );
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan indikator loading setelah selesai
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'), // Judul halaman
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong'; // Validasi input email
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true, // Sembunyikan karakter password
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong'; // Validasi input password
                  }
                  if (value.length < 6) {
                    return 'Password harus lebih dari 6 karakter'; // Syarat panjang password
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
                obscureText: true, // Sembunyikan karakter password
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong'; // Validasi konfirmasi password
                  }
                  return null;
                },
              ),
             
              const SizedBox(height: 24),

              // Tombol registrasi
              ElevatedButton(
                onPressed: _isLoading ? null : _register, // Matikan tombol jika sedang loading
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // Tampilkan loading indicator
                    : const Text('Register'), // Tampilkan teks biasa jika tidak loading
              ),
            ],
          ),
        ),
      ),
    );
  }
}