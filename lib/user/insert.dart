import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:ukk_2025/user/index.dart';
 

class InsertUser extends StatefulWidget {
  const InsertUser({super.key});

  @override
  State<InsertUser> createState() => _InsertUserState();
}

class _InsertUserState extends State<InsertUser> {
  final formKey = GlobalKey<FormState>();
  final user = TextEditingController();
  final pass = TextEditingController();
  final supabase = Supabase.instance.client;

  // Function to check if user already exists
  Future<bool> isUserExists(String username) async {
    try {
      final response = await supabase
          .from('user')
          .select('Username')
          .eq('Username', username)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<void> simpanUser() async {
    if (!formKey.currentState!.validate()) {
      return;  // Jika form tidak valid, tidak lanjutkan
    }

    final username = user.text;
    final password = pass.text;

    // Cek apakah username sudah ada
    bool userExists = await isUserExists(username);

    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah terdaftar!')),
      );
      return;
    }

    try {
      // Simpan data pengguna jika username belum terdaftar
      final response = await supabase.from('user').insert({
        'Username': username,
        'Password': password,
      }).select().single();

      if (response != null && response['user_id'] != null) {
        // Jika berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil ditambahkan!')),
        );

        // Arahkan ke halaman index setelah user berhasil disimpan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserTab()), // Ganti dengan halaman tujuan
        );
      } else {
        // Jika ada error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data pengguna!')),
        );
      }
    } catch (e) {
      // Menangani jika terjadi kesalahan saat query Supabase
      print('Error inserting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, coba lagi!')),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly] // Pastikan hanya angka
          : [], // Jika bukan angka, tidak ada format khusus
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) =>
          (value == null || value.isEmpty) ? '$label tidak boleh kosong' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah User',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(121, 255, 0, 128),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _buildTextField(user, 'Username'),
              const SizedBox(height: 10),
              _buildTextField(pass, 'Password', isNumber: true),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: simpanUser,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(121, 255, 0, 128)),
                child:
                    const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
