import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/insert.dart';
import 'package:ukk_2025/penjualan/update.dart';

class PenjualanTab extends StatefulWidget {
  const PenjualanTab({super.key});

  @override
  State<PenjualanTab> createState() => _PenjualanTabState();
}

class _PenjualanTabState extends State<PenjualanTab> {
  List<Map<String, dynamic>> penjualan = []; // Data penjualan
  List<Map<String, dynamic>> penjualanFiltered = []; // Data yang difilter berdasarkan pencarian
  bool isLoading = true; // Status loading data
  String searchQuery = ""; // Menyimpan query pencarian

  @override
  void initState() {
    super.initState();
    fetchPenjualan(); // Memanggil fungsi untuk mengambil data saat pertama kali dijalankan
  }

  // Fungsi untuk mengambil data penjualan dari Supabase
  Future<void> fetchPenjualan() async {
    setState(() {
      isLoading = true; // Mengatur status loading menjadi true
    });
    try {
      final response = await Supabase.instance.client.from('Penjualan').select();
      setState(() {
        penjualan = List<Map<String, dynamic>>.from(response); // Menyimpan data ke dalam list
        penjualanFiltered = penjualan; // Setel data yang difilter ke semua data awal
        isLoading = false; // Status loading selesai
      });
    } catch (e) {
      print('Error fetching penjualan: $e'); // Log error jika ada masalah
      setState(() {
        isLoading = false; // Tetap menonaktifkan status loading jika terjadi error
      });
    }
  }

  // Fungsi untuk menghapus penjualan berdasarkan ID
  Future<void> deletePenjualan(int id) async {
    try {
      await Supabase.instance.client.from('Penjualan').delete().eq('PenjualanID', id);
      fetchPenjualan(); // Memperbarui data setelah penghapusan
    } catch (e) {
      print('Error deleting penjualan: $e'); // Log error jika ada masalah
    }
  }

  // Fungsi untuk mencari penjualan berdasarkan query pencarian
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Penjualan"),
      ),
      body: Column(
        children: [
          // Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) {
                (query); // Memanggil fungsi pencarian saat input berubah
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
          // Menampilkan daftar penjualan atau pesan jika tidak ada data
          penjualanFiltered.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada penjualan', // Menampilkan pesan jika tidak ada data
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator()) // Menampilkan indikator loading
                      : ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: penjualanFiltered.length,
                          itemBuilder: (context, index) {
                            final jual = penjualanFiltered[index]; // Data penjualan per item
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      jual['TanggalPenjualan']?.toString() ?? 'tidak tersedia',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      jual['TotalHarga']?.toString() ?? 'Tidak tersedia',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      jual['PelangganID']?.toString() ?? 'Tidak tersedia',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                                            final PenjualanID = jual['PenjualanID'] ?? 0;
                                            if (PenjualanID != 0) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditPenjualan(PenjualanID: PenjualanID),
                                                ),
                                              );
                                            } else {
                                              print('ID penjualan tidak valid');
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Hapus Penjualan'),
                                                  content: const Text('Apakah Anda yakin ingin menghapus penjualan ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deletePenjualan(jual['PenjualanID']);
                                                        Navigator.pop(context); // Tutup dialog
                                                      },
                                                      child: const Text('Hapus'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
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
            MaterialPageRoute(builder: (context) => AddPenjualan()), // Navigasi ke halaman tambah penjualan
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
