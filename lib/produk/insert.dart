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
  final _formKey = GlobalKey<FormState>();

  // Function to check if the product already exists
  Future<bool> isProdukExists(String namaProduk) async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select('NamaProduk')
          .eq('NamaProduk', namaProduk)
          .single();

      return response != null; // Return true if product exists
    } catch (e) {
      print('Error checking if produk exists: $e');
      return false;
    }
  }

  // Function to add new product
  Future<void> tambahProduk() async {
    final namaProduk = _nmprd.text;
    final harga = double.tryParse(_harga.text) ?? 0;
    final stok = int.tryParse(_stok.text) ?? 0;

    // Form validation check
    if (_formKey.currentState!.validate()) {
      // Check if product already exists
      bool produkExist = await isProdukExists(namaProduk);

      if (produkExist) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Produk dengan nama yang sama sudah ada!'),
        ));
        return;
      }

      // Proceed to add product
      try {
        final response = await Supabase.instance.client.from('produk').insert({
          'NamaProduk': namaProduk,
          'Harga': harga,
          'Stok': stok,
        });

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menambah produk!')),
          );
        }
      } catch (e) {
        print('Error inserting produk: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambah produk!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nama Produk
              TextFormField(
                controller: _nmprd,
                decoration: const InputDecoration(
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
              const SizedBox(height: 16),
              // Harga
              TextFormField(
                controller: _harga,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null || double.tryParse(value) == 0) {
                    return 'Harga harus berupa angka yang lebih besar dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Stok
              TextFormField(
                controller: _stok,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.tryParse(value) == 0) {
                    return 'Stok harus berupa angka yang lebih besar dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Button for submitting form
              ElevatedButton(
                onPressed: tambahProduk,
                child: const Text('Tambah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ProdukDetailPage extends StatefulWidget {
  final Map<String, dynamic> produk;

  const ProdukDetailPage({Key? key, required this.produk}) : super(key: key);

  @override
  _ProdukDetailPageState createState() => _ProdukDetailPageState();
}

class _ProdukDetailPageState extends State<ProdukDetailPage> {
   int jumlahPesanan = 0;
    int totalHarga = 0;
    int stokakhir = 0;
    int stokawal = 0;

    void updateJumlahPesanan(int harga, int delta) {
    setState(() {
      stokakhir = stokawal - delta;
      if (stokakhir < 0) stokakhir = 0; 
      jumlahPesanan += delta;
      if (jumlahPesanan < 0) jumlahPesanan = 0; // Tidak boleh negatif
      totalHarga = jumlahPesanan * harga;
      if (totalHarga < 0) totalHarga = 0; // Tidak boleh negatif
    });
  }
  
Future<void> insertDetailPenjualan(int ProdukID, int PenjualanID, int jumlahPesanan, int totalHarga) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('detailpenjualan').insert({
        'ProdukID': ProdukID,
        'PenjualanID': PenjualanID,
        'JumlahProduk': jumlahPesanan,
        'Subtotal': totalHarga,
      });

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil disimpan!')),
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
      }
    } catch (e) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
    }
  }


  @override
  Widget build(BuildContext context) {
    final produk = widget.produk;
    final harga = produk['Harga'] ?? 0;
    final ProdukID = produk['ProdukID'] ?? 0;
    final PenjualanID = 1; // Contoh ID Penjualan (harus diganti sesuai logika Anda)

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk['NamaProduk'] ?? 'Detail Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.produk['NamaProduk'] ?? 'Nama Tidak Tersedia',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Harga: ${widget.produk['Harga'] ?? 'Tidak Tersedia'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Stok: ${widget.produk['Stok'] ?? 'Tidak Tersedia'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                      IconButton(
                        onPressed: () {
                          updateJumlahPesanan(harga, -1);
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$jumlahPesanan',
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        onPressed: () {
                          updateJumlahPesanan(harga, 1);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Masukkan Keranjang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (jumlahPesanan > 0) {
                      await insertDetailPenjualan(ProdukID, PenjualanID, jumlahPesanan, totalHarga);
                    }
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Beli Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[200],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


