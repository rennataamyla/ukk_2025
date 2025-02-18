import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPelanggan extends StatefulWidget {
  const AddPelanggan({super.key});

  @override
  State<AddPelanggan> createState() => _AddPelangganState();
}

class _AddPelangganState extends State<AddPelanggan> {
  final _nmplg = TextEditingController();
  final _alamat = TextEditingController();
  final _notlp = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to check if pelanggan already exists
  Future<bool> isPelangganExists(String namaPelanggan, String nomorTelepon) async {
    try {
      final response = await Supabase.instance.client
          .from('Pelanggan')
          .select('NamaPelanggan, NomorTelepon')
          .eq('NamaPelanggan', namaPelanggan)
          .or('NomorTelepon.eq.$nomorTelepon') // Check both fields
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking pelanggan existence: $e');
      return false;
    }
  }

  // Function to insert pelanggan
  Future<void> langgan() async {
    if (_formKey.currentState!.validate()) {
      final String NamaPelanggan = _nmplg.text;
      final String Alamat = _alamat.text;
      final String NomorTelepon = _notlp.text;

      // Cek apakah pelanggan sudah ada
      bool pelangganExists = await isPelangganExists(NamaPelanggan, NomorTelepon);

      if (pelangganExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan sudah terdaftar!')),
        );
        return;
      }

      // Insert pelanggan data if not exists
      final response = await Supabase.instance.client.from('Pelanggan').insert(
        {
          'NamaPelanggan': NamaPelanggan,
          'Alamat': Alamat,
          'NomorTelepon': NomorTelepon,
        },
      );

      if (response.error == null) {
        // Navigate to Homepage on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan pelanggan!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pelanggan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nmplg,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamat,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlp,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: langgan,
                child: const Text('Tambah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy Homepage class for navigation
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: const Center(
        child: Text('Selamat Datang di Homepage!'),
      ),
    );
  }
}
