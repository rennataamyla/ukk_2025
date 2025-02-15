import 'package:flutter/material.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProduk extends StatefulWidget {
  const AddProduk({super.key});

  @override
  State<AddProduk> createState() => _AddProdukState();
}

class _AddProdukState extends State<AddProduk> {
  final _nmprd = TextEditingController();
  final _harga = TextEditingController();
  final _stok = TextEditingController();
  final _fromkey = GlobalKey<FormState>();

  Future<void> produk() async{
    if(_fromkey.currentState!.validate()) {
      final NamaProduk = _nmprd.text;
      final Harga = double.tryParse(_harga.text) ?? 0;
      final Stok = int.tryParse(_stok.text) ?? 0;

     if (Harga == 0 || Stok == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harga dan Stok harus berupa angka')),
        );
        return;
      }

      final response = await Supabase.instance.client.from('produk').insert(
        {
          'NamaProduk' : NamaProduk,
          'Harga' : Harga,
          'Stok': Stok,
        }
      );
        if (response != null) {
        Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => Homepage()),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child:  Form(
          key: _fromkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
           children: [
              TextFormField(
                controller: _nmprd,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _harga,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border:OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty){
                  return 'tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stok,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: produk, 
              child: Text('Tambah'))
            ],
          ),
        ),
      ),
    );
  }
}