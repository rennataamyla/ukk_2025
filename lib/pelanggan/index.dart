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
 List<Map<String, dynamic>> pelanggan = [];
  List<Map<String, dynamic>> filteredPelanggan = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client.from('Pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        filteredPelanggan = pelanggan;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
      setState(() => isLoading = false);
    }
  }

  void filterPelanggan(String query) {
    setState(() {
      filteredPelanggan = pelanggan.where((item) {
        final name = item['NamaPelanggan']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<bool> cekPelangganAda(String namaPelanggan) async {
    final response = await Supabase.instance.client
        .from('Pelanggan')
        .select()
        .eq('NamaPelanggan', namaPelanggan);

    return response.isNotEmpty; // True jika pelanggan sudah ada
  }

  Future<void> tambahPelanggan(Map<String, dynamic> pelangganBaru) async {
    bool sudahAda = await cekPelangganAda(pelangganBaru['NamaPelanggan']);

    if (sudahAda) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan dengan nama ini sudah ada!')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('Pelanggan').insert(pelangganBaru);
      fetchPelanggan();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan berhasil ditambahkan!')),
      );
    } catch (e) {
      print('Error menambahkan pelanggan: $e');
    }
  }

  Future<void> deletePelanggan(int id) async {
    try {
      await Supabase.instance.client.from('Pelanggan').delete().eq('PelangganID', id);
      fetchPelanggan();
    } catch (e) {
      print('Error deleting pelanggan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Pelanggan"), // Menambahkan teks "Pelanggan"
            SizedBox(width: 10), // Memberikan ruang antara teks dan TextField
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Cari Pelanggan...",
                  labelStyle: const TextStyle(color: Colors.blueGrey),
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: filterPelanggan,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredPelanggan.isEmpty
              ? Center(child: Text('Tidak ada pelanggan'))
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: filteredPelanggan.length,
                  itemBuilder: (context, index) {
                    final langgan = filteredPelanggan[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langgan['NamaPelanggan'] ?? 'Tidak tersedia',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 4),
                            Text(
                              langgan['Alamat'] ?? 'Alamat Tidak tersedia',
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              langgan['NomorTelepon'] ?? 'Tidak tersedia',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.justify,
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () {
                                    final PelangganID = langgan['PelangganID'] ?? 0;
                                    if (PelangganID != 0) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPelanggan(PelangganID: PelangganID),
                                        ),
                                      );
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
                                                deletePelanggan(langgan['PelangganID']);
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
        onPressed: () async {
          final pelangganBaru = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPelanggan()),
          );

          if (pelangganBaru != null) {
            tambahPelanggan(pelangganBaru);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}