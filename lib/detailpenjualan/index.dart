import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/detailpenjualan/cetakpdf.dart';
import 'package:ukk_2025/homepage.dart';

class DetailPenjualanTab extends StatefulWidget {
  const DetailPenjualanTab({super.key});

  @override
  State<DetailPenjualanTab> createState() => _DetailPenjualanTabState();
}

class _DetailPenjualanTabState extends State<DetailPenjualanTab> {
  List<Map<String, dynamic>> detaill = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchdetail();
  }

  Future<void> fetchdetail() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await Supabase.instance.client.from('detailpenjualan').select();
      setState(() {
        detaill = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: detaill.length,
              itemBuilder: (context, index) {
                final detail = detaill[index]; 
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail ID: ${detail['Detailid']?.toString() ?? '-'}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        _buildDetailRow('Penjualan ID', detail['Penjualanid']),
                        _buildDetailRow('Produk ID', detail['Produkid']),
                        _buildDetailRow('Jumlah Produk', detail['JumlahProduk']),
                        _buildDetailRow('Subtotal', detail['Subtotal']),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [ 
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}