import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganTab extends StatefulWidget {
  const PelangganTab({super.key});

  @override
  State<PelangganTab> createState() => _PelangganTabState();
}

class _PelangganTabState extends State<PelangganTab> {
  List<Map<String, dynamic>> pelanggan = [];
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    fetchPelanggan();
  }

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
      body: pelanggan.isEmpty
      ? Center(
        child: Text('Tidak ada pelanggan',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
      ),
    )

    );
    )
    
  }
}