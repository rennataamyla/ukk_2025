import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/insert.dart'; // Pastikan AddPenjualan diimpor

class PenjualanTab extends StatefulWidget {
  const PenjualanTab({super.key});

  @override
  State<PenjualanTab> createState() => _PenjualanTabState();
}

class _PenjualanTabState extends State<PenjualanTab> {
  List<Map<String, dynamic>> penjualan = [];
  List<Map<String, dynamic>> penjualanFiltered = []; // Untuk menyimpan hasil pencarian

  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchPenjualan();
  }

  // Fungsi untuk mengambil data penjualan dari Supabase
  Future<void> fetchPenjualan() async {
    setState(() {
      isLoading = true; // Menetapkan status loading menjadi true saat mengambil data
    });

    try {
      final response = await Supabase.instance.client.from('Penjualan').select();
      if (response == null) {
        setState(() {
          penjualan = List<Map<String, dynamic>>.from(response);
          penjualanFiltered = penjualan;
          isLoading = false; // Menetapkan status loading menjadi false setelah data berhasil diambil
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Menangani error jika ada masalah
        print('Error fetching penjualan: ${response}');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Tetap menonaktifkan status loading jika terjadi error
      });
      print('Error fetching penjualan: $e'); // Mencetak error yang terjadi
    }
  }

  // Fungsi untuk mencari penjualan berdasarkan kueri
  void searchPenjualan(String query) {
    setState(() {
      searchQuery = query;
      penjualanFiltered = penjualan.where((jual) {
        return jual['pelanggan']['NamaPelanggan'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Fungsi untuk menghapus penjualan berdasarkan ID
  Future<void> deletePenjualan(int id) async {
    try {
      final response = await Supabase.instance.client.from('Penjualan').delete().eq('PenjualanID', id);
      if (response.error == null) {
        // Segarkan daftar setelah penghapusan
        fetchPenjualan();
      } else {
        print('Error deleting penjualan: ${response.error!.message}');
      }
    } catch (e) {
      print('Error deleting penjualan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) {
                searchPenjualan(query);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          // ListView untuk menampilkan penjualan yang sudah difilter
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Menampilkan indikator loading
                : ListView.builder(
                    itemCount: penjualanFiltered.length,
                    itemBuilder: (context, index) {
                      final item = penjualanFiltered[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.2),
                                blurRadius: 8.0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            title: Text(
                              item['pelanggan']['NamaPelanggan'],
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Total harga: ${item['TotalHarga']}\nTanggal: ${item['TanggalPenjualan']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Menghapus penjualan
                                deletePenjualan(item['PenjualanID']);
                              },
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
        onPressed: () async {
          var result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddPenjualan()), // Navigasi ke AddPenjualan
          );

          if (result == true) {
            fetchPenjualan(); // Segarkan data jika penjualan baru ditambahkan
          }
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.brown[600],
      ),
    );
  }
}
