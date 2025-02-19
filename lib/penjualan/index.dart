import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'package:ukk_2025/detailpenjualan/cetakpdf.dart';
import 'package:ukk_2025/penjualan/insert.dart';
import 'package:ukk_2025/penjualan/update.dart';

class PenjualanTab extends StatefulWidget {
  final int? PenjualanID;
  final int? PelangganID;
  final int? TotalHarga;
  final String? TanggalPenjualan;

  const PenjualanTab({
    super.key,
    this.PelangganID,
    this.PenjualanID,
    this.TanggalPenjualan,
    this.TotalHarga,
  });

  @override
  State<PenjualanTab> createState() => _PenjualanTabState();
}

final supabase = Supabase.instance.client;
final TextEditingController cari = TextEditingController();
List<bool> dipilihItem = [];
List<Map<String, dynamic>> penjualanList = [];
List<Map<String, dynamic>> mencariPenjualan = [];

class _PenjualanTabState extends State<PenjualanTab> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final result = ModalRoute.of(context)?.settings.arguments as bool?;
    if (result == true) {
      ambilPenjualan();
    }
  }

  @override
  void initState() {
    super.initState();
    ambilPenjualan();
    cari.addListener(pencarianPenjualan);
  }

  Future<void> ambilPenjualan() async {
    try {
      final data = await supabase.from('penjualan').select();
      setState(() {
        penjualanList = List<Map<String, dynamic>>.from(data);
        dipilihItem = List.generate(penjualanList.length, (_) => false);
        mencariPenjualan = penjualanList;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void pencarianPenjualan() {
    setState(() {
      mencariPenjualan = penjualanList
          .where((penjualan) =>
              penjualan['PelangganID']?.toString().toLowerCase().contains(cari.text.toLowerCase()) ??
              false)
          .toList();
    });
  }

  Future<void> deletePenjualan(int penjualanID) async {
    try {
      await supabase.from('penjualan').delete().eq('PenjualanID', penjualanID);
      ambilPenjualan(); // Refresh the list after deletion
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penjualan berhasil dihapus')));
    } catch (e) {
      print('Error deleting penjualan: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus penjualan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: cari,
              decoration: InputDecoration(
                labelText: "Cari Penjualan...",
                labelStyle: const TextStyle(color: Colors.blueGrey),
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: mencariPenjualan.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak Ada Data Penjualan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: mencariPenjualan.length,
                    itemBuilder: (context, index) {
                      final pen = mencariPenjualan[index];
                      return Card(
                        color: Colors.blue[50],
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Checkbox(
                                value: dipilihItem[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    dipilihItem[index] = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanggal: ${pen['TanggalPenjualan'] ?? 'Tidak tersedia'}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Total Harga: ${pen['TotalHarga'] != null ? pen['TotalHarga'].toString() : 0}',
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pelanggan ID: ${pen['PelangganID']?.toString() ?? 'Tidak tersedia'}',
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color.fromARGB(255, 120, 151, 205)),
                                onPressed: () {
                                  final penjualanID = pen['PenjualanID'] ?? 0;
                                  if (penjualanID != 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPenjualan(PenjualanID: penjualanID),
                                      ),
                                    );
                                  } else {
                                    print('ID penjualan tidak valid');
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
                                        title: const Text('Hapus Penjualan'),
                                        content: const Text('Apakah Anda yakin ingin menghapus penjualan ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final penjualanID = pen['PenjualanID'] ?? 0;
                                              if (penjualanID != 0) {
                                                deletePenjualan(penjualanID);
                                              }
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
                        ),
                      );
                    },
                  ),
          ),
          if (dipilihItem.contains(true))
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  final selectedPenjualan = <Map<String, dynamic>>[];
                  int totalHarga = 0;

                  // Menghitung total harga untuk penjualan yang dipilih
                  for (int i = 0; i < penjualanList.length; i++) {
                    if (dipilihItem[i]) {
                      selectedPenjualan.add(penjualanList[i]);
                      final harga = penjualanList[i]['TotalHarga'];

                      if (harga != null) {
                        try {
                          totalHarga += (harga is int)
                              ? harga
                              : (harga is double)
                                  ? harga.toInt()  // Jika double, konversi ke int
                                  : 0;             // Jika bukan int atau double, anggap sebagai 0
                        } catch (e) {
                          print("Error pada TotalHarga: $e");
                        }
                      }
                    }
                  }

                  if (selectedPenjualan.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CetakPdfTab(
                          selectedPenjualan: selectedPenjualan,
                          tanggalPesanan: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          totalHarga: totalHarga,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tidak ada penjualan yang dipilih')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.white,
                ),
                child: const Text('Checkout', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }
}
