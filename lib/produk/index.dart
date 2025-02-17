import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/index.dart';
import 'package:ukk_2025/produk/insert.dart';
import 'package:ukk_2025/produk/update.dart';

class ProdukTab extends StatefulWidget {
  const ProdukTab({super.key});

  @override
  State<ProdukTab> createState() => _ProdukTabState();
}

class _ProdukTabState extends State<ProdukTab> {
  List<Map<String, dynamic>> produk = [];
  List<Map<String, dynamic>> filteredProduk = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProduk();
    _searchController.addListener(_onSearchChanged);
  }

  // Fetch all products
  Future<void> fetchProduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
        filteredProduk = List.from(produk); // Set initial filtered list to all products
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching produk: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Handle search input changes
  void _onSearchChanged() {
    setState(() {
      filteredProduk = produk.where((product) {
        final name = product['NamaProduk'].toString().toLowerCase();
        final searchQuery = _searchController.text.toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    });
  }

  // Delete product
  Future<void> deleteProduk(int ProdukID) async {
    try {
      await Supabase.instance.client.from('produk').delete().eq('ProdukID', ProdukID);
      fetchProduk();
    } catch (e) {
      print('Error deleting produk: $e');
    }
  }

  // Buy product functionality
  Future<void> beliProduk(int ProdukID, int jumlah) async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select('Stok')
          .eq('ProdukID', ProdukID)
          .single();

      final currentStock = response['Stok'] as int;
      if (currentStock >= jumlah) {
        final newStock = currentStock - jumlah;
        await Supabase.instance.client
            .from('produk')
            .update({'Stok': newStock})
            .eq('ProdukID', ProdukID);

        fetchProduk();
        print('Produk berhasil dibeli! Stok baru: $newStock');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Stok Tidak Mencukupi'),
              content: Text('Hanya tersedia $currentStock produk.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error membeli produk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Produk')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredProduk.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak Ada produk',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: filteredProduk.length,
                        itemBuilder: (context, index) {
                          final product = filteredProduk[index];
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
                                      'Stok: ${product['Stok']?.toString() ?? 'Tidak tersedia'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14,
                                      ),
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 120, 151, 205)),
                                          onPressed: () {
                                            final ProdukID = product['ProdukID'] ?? 0;
                                            if (ProdukID != 0) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => updateproduk(ProdukID: ProdukID),
                                                ),
                                              );
                                            } else {
                                              print('ID produk tidak valid');
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 83, 119, 144)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Hapus Produk'),
                                                  content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteProduk(product['ProdukID']);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Hapus'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.shopping_cart, color: Color.fromARGB(255, 129, 168, 192)),
                                          onPressed: () {
                                            final ProdukID = product['ProdukID'] ?? 0;
                                            if (ProdukID != 0) {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  final TextEditingController qtyController = TextEditingController();
                                                  return AlertDialog(
                                                    title: const Text('Beli Produk'),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text('Masukkan jumlah yang ingin dibeli:'),
                                                        TextField(
                                                          controller: qtyController,
                                                          keyboardType: TextInputType.number,
                                                          decoration: InputDecoration(hintText: 'Jumlah'),
                                                        ),
                                                      
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          final jumlah = int.tryParse(qtyController.text) ?? 0;
                                                          if (jumlah > 0) {
                                                            beliProduk(ProdukID, jumlah);
                                                            Navigator.pop(context);
                                                          } else {
                                                            print('Jumlah tidak valid');
                                                          }
                                                        },
                                                        child: const Text('Beli'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              print('ID produk tidak valid');
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProduk()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
