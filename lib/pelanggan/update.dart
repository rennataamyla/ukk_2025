import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';

class updatePelanggan extends StatefulWidget {
  const updatePelanggan({super.key});

  @override
  State<updatePelanggan> createState() => _updatePelangganState();
}

class _updatePelangganState extends State<updatePelanggan>
   final _nmplg = TextEditingController();
  final _alamat = TextEditingController();
  final _notlp = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Fungsi untuk menambahkan pelanggan
  Future<void> langgan() async {
    if (_formKey.currentState!.validate()) {
      final String NamaPelanggan = _nmplg.text;
      final String Alamat = _alamat.text;
      final String NomorTelepon = _notlp.text;

      // Insert pelanggan data
      final response = await Supabase.instance.client.from('Pelanggan').insert(
        {
          'NamaPelanggan': NamaPelanggan,
          'Alamat': Alamat,
          'NomorTelepon': NomorTelepon,
        },
      );

      if (response.error == null) {
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      } else {
       
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${response.error!.message}'),
        ));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
        key: _fromkey,
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nmprd,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
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
                  controller: _stok,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                     return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: updateproduk,
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  