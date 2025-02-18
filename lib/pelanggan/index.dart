import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pelanggan/insert.dart';
import 'package:ukk_2025/pelanggan/update.dart';

class PelangganTab extends StatefulWidget {
  const PelangganTab({super.key});

  @override
  State<PelangganTab> createState() => _PelangganTabState();
}

class _PelangganTabState extends State<PelangganTab> {
  List<Map<String, dynamic>> Pelanggan = []; // Menyimpan data pelanggan
  List<Map<String, dynamic>> filteredPelanggan = []; // Menyimpan data pelanggan yang sudah difilter
  bool isLoading = true; // Status loading data
  String searchQuery = ""; // Kontrol pencarian

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  // Fungsi untuk mengambil data pelanggan dari Supabase
  Future<void> fetchPelanggan() async {
    setState(() {
      isLoading = true; // Mengatur status loading menjadi true
    });
    try {
      final response = await Supabase.instance.client.from('Pelanggan').select();
      setState(() {
        Pelanggan = List<Map<String, dynamic>>.from(response); // Menyimpan data ke dalam list
        filteredPelanggan = List.from(Pelanggan); // Menyalin data awal ke list filter
        isLoading = false; // Status loading selesai
      });
    } catch (e) {
      print('Error fetching pelanggan: $e'); // Log error jika ada masalah
      setState(() {
        isLoading = false; // Tetap menonaktifkan status loading jika terjadi error
      });
    }
  }

  // Fungsi untuk menyaring data pelanggan berdasarkan pencarian
  void searchPelanggan(String query) {
    setState(() {
      searchQuery = query;
      // Pencarian dilakukan berdasarkan NamaPelanggan
      filteredPelanggan = Pelanggan.where((pelanggan) {
        return pelanggan['NamaPelanggan']
            .toLowerCase()
            .contains(query.toLowerCase()); // Pencarian case-insensitive
      }).toList();
    });
  }

  // Fungsi untuk menghapus data pelanggan berdasarkan ID
  Future<void> deletePelanggan(int id) async {
    try {
      await Supabase.instance.client.from('Pelanggan').delete().eq('PelangganID', id);
      fetchPelanggan(); // Memperbarui data setelah penghapusan
    } catch (e) {
      print('Error deleting pelanggan: $e'); // Log error jika ada masalah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelanggan'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) {
                searchPelanggan(query); // Fungsi pencarian saat input berubah
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
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Menampilkan indikator loading saat data sedang dimuat
          : filteredPelanggan.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada pelanggan yang sesuai dengan pencarian',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8), // Padding keseluruhan
                  itemCount: filteredPelanggan.length, // Jumlah item yang sudah difilter
                  itemBuilder: (context, index) {
                    final pelanggan = filteredPelanggan[index]; // Data pelanggan per item
                    return Card(
                      elevation: 6, // Bayangan yang lebih tajam
                      margin: EdgeInsets.symmetric(vertical: 10), // Margin antar kartu
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)), // Sudut yang lebih halus
                      child: Padding(
                        padding: EdgeInsets.all(12), // Padding dalam kartu
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Posisi konten
                          children: [
                            Text(
                              pelanggan['NamaPelanggan'] ?? 'Pelanggan tidak tersedia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              pelanggan['Alamat'] ?? 'Alamat Tidak tersedia',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              pelanggan['NomorTelepon'] ?? 'Tidak tersedia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8), // Jarak vertikal
                            // Menambahkan ID Pelanggan
                            Text(
                              'ID Pelanggan: ${pelanggan['PelangganID'] ?? 'Tidak tersedia'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end, // Posisi tombol
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () {
                                    final PelangganID = pelanggan['PelangganID'] ?? 0;
                                    if (PelangganID != 0) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPelanggan(PelangganID: PelangganID),
                                        ),
                                      );
                                    } else {
                                      print('ID pelanggan tidak valid');
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
                                          title: const Text('Hapus Pelanggan'),
                                          content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deletePelanggan(pelanggan['PelangganID']);
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPelanggan()), // Navigasi ke halaman tambah pelanggan
          );
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 125, 175, 216), // Warna tombol tambah
      ),
    );
  }
}
