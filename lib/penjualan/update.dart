import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';

  class EditPenjualan extends StatefulWidget {
    final int PenjualanID;

    const EditPenjualan({super.key, required this.PenjualanID});

    @override
    State<EditPenjualan> createState() => _EditPenjualanState();
  }

  class _EditPenjualanState extends State<EditPenjualan> {
    final _tgl = TextEditingController();
    final _ttl = TextEditingController();
    final _plgid = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    @override
    void initState() {
      super.initState();
      _loadPenjualanData();
    }

    // Fungsi untuk memuat data pelanggan berdasarkan ID
    Future<void> _loadPenjualanData() async {
      final data = await Supabase.instance.client
          .from('Penjualan')
          .select()
          .eq('PenjualanID', widget.PenjualanID)
          .single();

      setState(() {
        _tgl.text = data['TanggalPenjualan'] ?? '';
        _ttl.text = data['TotalHarga']?.toString() ?? '';
        _plgid.text = data['PelangganID']?.toString() ?? '';
       
      });
    }

  // EditPenjualan.dart
  Future<void> updatePelanggan() async {
    if (_formKey.currentState!.validate()) {

      await Supabase.instance.client.from('Pelanggan').update({
        'TanggalPenjualan': _tgl.text,
        'TotalHarga': _ttl.text,
        'PelangganID': _plgid.text,
        
      }).eq('PenjualanID', widget.PenjualanID);

      // Navigasi ke PelangganTab setelah update, dengan menghapus semua halaman sebelumnya dari stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
         // Hapus semua halaman sebelumnya
      );
    }
  }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Penjualan'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _tgl,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Penjualan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _ttl,
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
                  controller: _plgid,
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
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: updatePelanggan,
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }