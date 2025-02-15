import 'package:flutter/material.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class updateproduk extends StatefulWidget {
  final int ProdukID;

  const updateproduk({super.key, required this.ProdukID});

  @override
  State<updateproduk> createState() => _updateprodukState();
}

class _updateprodukState extends State<updateproduk> {
  final _nmprd = TextEditingController();
  final _harga = TextEditingController();
  final _stok = TextEditingController();
  final _fromkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
     _loadProdukData();
  }

  Future<void> _loadProdukData() async{
    final data = await Supabase.instance.client
    .from('produk')
    .select()
    .eq('ProdukID', widget.ProdukID)
    .single();

  setState(() {
    _nmprd.text = data['NamaProduk'] ?? '';
     _harga.text = data['Harga']?.toString() ?? '';
     _stok.text = data['Stok']?.toString() ?? '';
  });
}

Future<void> updateproduk() async{
  if (_fromkey.currentState!.validate()) {
    await Supabase.instance.client.from('produk').update({
      'NamaProduk': _nmprd.text,
      'Harga': _harga.text,
      'Stok': _stok.text,
    }).eq('ProdukID', widget.ProdukID);


    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) =>Homepage()),
      (route) => false,
    );
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
  }