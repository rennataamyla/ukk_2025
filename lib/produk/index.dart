import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';

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

  // Update jumlah pesanan dan stok produk
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

  // Fungsi untuk membuat entri penjualan di tabel 'penjualan'
  Future<int?> createPenjualan(int PelangganID, int totalHarga) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('penjualan').insert({
        'PelangganID': PelangganID,
        'TotalHarga': totalHarga,
        'TanggalPenjualan': DateTime.now().toIso8601String(),
      }).select().single();

      if (response == null) {
        return response['PenjualanID'];  // Mengembalikan ID penjualan yang baru
      } else {
        print("Error creating Penjualan: ${response}");
        return null;
      }
    } catch (e) {
      print("Error creating Penjualan: $e");
      return null;
    }
  }

  // Fungsi untuk memasukkan detail produk ke dalam tabel 'detailpenjualan'
  Future<void> insertDetailPenjualan(int produkID, int penjualanID, int jumlahPesanan, int totalHarga) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('detailpenjualan').insert({
        'ProdukID': produkID,
        'PenjualanID': penjualanID,
        'JumlahProduk': jumlahPesanan,
        'Subtotal': totalHarga,
      }).select().single();

      if (response == null) {
        print("Detail Penjualan berhasil dimasukkan!");
      } else {
        print("Error inserting detailpenjualan: ${response}");
      }
    } catch (e) {
      print("Error inserting detailpenjualan: $e");
    }
  }

  // Fungsi yang menangani proses pembelian
  Future<void> handleBeliSekarang() async {
    final produk = widget.produk;
    final harga = produk['Harga'] ?? 0;
    final ProdukID = produk['ProdukID'] ?? 0;
    final PelangganID = 1; // Ganti dengan ID pelanggan yang sedang login

    // Membuat Penjualan terlebih dahulu
    final penjualanID = await createPenjualan(PelangganID, totalHarga);
    
    if (penjualanID != null && penjualanID > 0) {
      // Jika penjualan berhasil dibuat, masukkan detailpenjualan
      await insertDetailPenjualan(ProdukID, penjualanID, jumlahPesanan, totalHarga);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil disimpan!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat penjualan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final produk = widget.produk;
    final harga = produk['Harga'] ?? 0;
    final ProdukID = produk['ProdukID'] ?? 0;

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
                  onPressed: handleBeliSekarang,
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
