  import 'package:flutter/material.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:ukk_2025/homepage.dart';

  class AddPenjualan extends StatefulWidget {
    const AddPenjualan({super.key});

    @override
    State<AddPenjualan> createState() => _AddPenjualanState();
  }

  class _AddPenjualanState extends State<AddPenjualan> {
    final _totalharga = TextEditingController();
    final _pelangganid = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    // Function to insert the pelanggan
    Future<void> jualan() async {
      if (_formKey.currentState!.validate()) {
        final String TotalHarga = _totalharga.text;
        final String PelangganID = _pelangganid.text;
        

        // Insert pelanggan data
        final response = await Supabase.instance.client.from('Penjualan').insert(
          {
            'TotalHarga': TotalHarga,
            'PelangganID': PelangganID,
           
          },
        );

        if (response == null) {
          // Navigate to Homepage on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
        } else {
          // Show error message
         Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Penjualan'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _totalharga,
                  decoration: const InputDecoration(
                    labelText: 'Total Harga',
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
                  controller: _pelangganid,
                  decoration: const InputDecoration(
                    labelText: 'PelangganID',
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
                ElevatedButton(
                  onPressed: jualan,
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  