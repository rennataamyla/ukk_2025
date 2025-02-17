import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:ukk_2025/user/index.dart';  // Tambahkan ini untuk FilteringTextInputFormatter

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

  Future<void> simpanUser() async {
    if (!formKey.currentState!.validate()) {
      final simpanData = await supabase
          .from('user')
          .select('Username')
          .eq('Username', user.text)
          .maybeSingle();

      if (simpanData != null) {
        // Untuk menampilkan pesan error jika data sudah ada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak boleh ada data ganda!')),
        );
        return;
      }

      // Untuk menyimpan data jika data belum ada
      await supabase.from('user').insert({
        'Username': user.text,
        'Password': pass.text,
      });

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const UserTab()));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]  // Pastikan ini sudah benar
          : [], // Jika bukan angka, maka tidak ada format input khusus
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
        title: const Text('Tambah Pelanggan',
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
