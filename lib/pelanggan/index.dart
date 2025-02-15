import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 // Pastikan ini mengarah ke file AddPelanggan.dart
import 'package:ukk_2025/pelanggan/insert.dart';
import 'package:ukk_2025/pelanggan/update.dart';  // Buat file UpdatePelanggan.dart untuk menangani update

class PelangganTab extends StatefulWidget {
  const PelangganTab({super.key});

  @override
  State<PelangganTab> createState() => _PelangganTabState();
}

class _PelangganTabState extends State<PelangganTab> {
  List<Map<String, dynamic>> pelanggan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  // Fetch all customers
  Future<void> fetchPelanggan() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('Pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete customer
  Future<void> deletePelanggan(int id) async {
    try {
      await Supabase.instance.client.from('Pelanggan').delete().eq('PelangganID', id);
      fetchPelanggan();
    } catch (e) {
      print('Error deleting pelanggan: $e');
    }
  }

  // Add new customer
  Future<void> addPelanggan(String nama, String email, String alamat, String noTelepon) async {
    try {
      await Supabase.instance.client.from('Pelanggan').insert([{
        'NamaPelanggan': nama,
        'Email': email,
        'Alamat': alamat,
        'NomorTelepon': noTelepon,
      }]);
      fetchPelanggan();
    } catch (e) {
      print('Error adding pelanggan: $e');
    }
  }

  // Update customer
  Future<void> updatePelanggan(int id, String nama, String email, String alamat, String noTelepon) async {
    try {
      await Supabase.instance.client.from('Pelanggan').update({
        'NamaPelanggan': nama,
        'Email': email,
        'Alamat': alamat,
        'NomorTelepon': noTelepon,
      }).eq('PelangganID', id);
      fetchPelanggan();
    } catch (e) {
      print('Error updating pelanggan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelanggan'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pelanggan.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada pelanggan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: pelanggan.length,
                  itemBuilder: (context, index) {
                    final customer = pelanggan[index];
                    return ListTile(
                      title: Text(customer['NamaPelanggan'] ?? 'Nama tidak tersedia'),
                      subtitle: Text(
                        '${customer['Email'] ?? 'Email tidak tersedia'}\n${customer['Alamat'] ?? 'Alamat tidak tersedia'}\n${customer['NomorTelepon'] ?? 'Nomor Telepon tidak tersedia'}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deletePelanggan(customer['PelangganID']),
                      ),
                      
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPelanggan()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
