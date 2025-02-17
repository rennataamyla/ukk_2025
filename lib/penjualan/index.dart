import 'package:flutter/material.dart';
import 'package:ukk_2025/pelanggan/insert.dart';
import 'package:ukk_2025/pelanggan/update.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/insert.dart';
import 'package:ukk_2025/penjualan/update.dart';

class penjualanTab extends StatefulWidget {
  const penjualanTab({super.key});

  @override
  State<penjualanTab> createState() => _penjualanTabState();
}

class _penjualanTabState extends State<penjualanTab> {
  List<Map<String, dynamic>> Penjualan = []; // Menyimpan data pelanggan
  bool isLoading = true; // Status loading data

  @override
  void initState() {
    super.initState();
    fetchPenjualan(); // Memanggil fungsi untuk mengambil data pelanggan saat inisialisasi
  }

  // Fungsi untuk mengambil data pelanggan dari Supabase
  Future<void> fetchPenjualan() async {
    setState(() {
      isLoading = true; // Mengatur status loading menjadi true
    });
    try {
      final response = await Supabase.instance.client.from('Penjualan').select();
      setState(() {
        Penjualan = List<Map<String, dynamic>>.from(response); // Menyimpan data ke dalam list
        isLoading = false; // Status loading selesai
      });
    } catch (e) {
      print('Error fetching pelanggan: $e'); // Log error jika ada masalah
      setState(() {
        isLoading = false; // Tetap menonaktifkan status loading jika terjadi error
      });
    }
  }

  // Fungsi untuk menghapus data pelanggan berdasarkan ID
  Future<void> deletePelanggan(int id) async {
    try {
      await Supabase.instance.client.from('Penjualan').delete().eq('PenjualanID', id);
      fetchPenjualan(); // Memperbarui data setelah penghapusan
    } catch (e) {
      print('Error deleting penjualan: $e'); // Log error jika ada masalah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Penjualan.isEmpty // Jika data kosong
          ? Center(
              child: Text(
                'Tidak ada penjualan', // Tampilkan teks ini
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder( // Menampilkan data dalam bentuk grid
              padding: EdgeInsets.all(8), // Padding keseluruhan
              itemCount: Penjualan.length, // Jumlah item
              itemBuilder: (context, index) {
                final jual = Penjualan[index]; // Data pelanggan per item
                return Card(
                  elevation: 4, // Elevasi bayangan kartu
                  margin: EdgeInsets.symmetric(vertical: 8), // Margin antar kartu
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)), // Radius sudut kartu
                  child: Padding(
                    padding: EdgeInsets.all(12), // Padding dalam kartu
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Posisi konten
                      children: [
                        // Menampilkan nama pelanggan
                        Text(
                          jual['TanggalPenjualan']?.toString() ?? 'tidak tersedia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 4), // Jarak vertikal
                        // Menampilkan alamat pelanggan
                        Text(
                          jual['TotalHarga']?.toString() ?? 'Tidak tersedia',
                          style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 16, color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8), // Jarak vertikal
                        // Menampilkan nomor telepon pelanggan
                        Text(
                          jual['PelangganID']?.toString() ?? 'Tidak tersedia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const Divider(), // Garis pemisah
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end, // Posisi tombol
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () {
                                final PenjualanID = jual['PenjualanID'] ?? 0; // Pastikan ini sesuai dengan kolom di database
                                if (PenjualanID != 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPenjualan(PenjualanID: PenjualanID)
                                    ),
                                  );
                                } else {
                                  print('ID pelanggan tidak valid'); // Log jika ID invalid
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                // Konfirmasi sebelum menghapus
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
                                            deletePelanggan(jual['PenjualanID']); // Panggil fungsi hapus
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPenjualan()), // Navigasi ke halaman tambah pelanggan
          );
        },
        child: Icon(Icons.add), // Ikon tombol tambah
      ),
    );
  }
}