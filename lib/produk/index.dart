import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/produk/insert.dart'; // Asumsi file ini digunakan untuk menambahkan produk
import 'package:ukk_2025/produk/update.dart'; // Asumsi file ini digunakan untuk memperbarui produk

class ProdukTab extends StatefulWidget {
  const ProdukTab({super.key});

  @override
  State<ProdukTab> createState() => _ProdukTabState();
}

class _ProdukTabState extends State<ProdukTab> {
  List<Map<String, dynamic>> produk = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  // Mengambil produk dari Supabase
  Future<void> fetchProduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = 
      await Supabase.instance.client
      .from('produk')
      .select();
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching produk: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> deleteProduk(int ProdukID) async {
    try {
      await Supabase.instance.client
      .from('produk')
      .delete()
      .eq('ProdukID', ProdukID);
  
      fetchProduk(); 
    } catch (e) {
      print('Error deleting produk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Produk')),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) 
          : produk.isEmpty
              ? Center(
                  child: Text(
                    'Tidak Ada produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: produk.length,
                  itemBuilder: (context, index) {
                    final product = produk[index]; // Memperbaiki nama variabel 'roduk' menjadi 'product'
                    return InkWell(
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['NamaProduk']?.toString() ?? 'Produk tidak tersedia',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                product['Harga']?.toString() ?? 'Harga Tidak tersedia',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                product['Stok']?.toString() ?? 'Tidak tersedia',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () {
                                      final ProdukID =
                                      product['ProdukID'] ?? 0;
                                      if (ProdukID != 0) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => editproduk(ProdukID: ProdukID)))
                                        ),
                                      };
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
