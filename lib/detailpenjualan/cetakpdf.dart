import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class CetakPdfTab extends StatefulWidget {
  final List<Map<String, dynamic>> selectedPenjualan;
  final String tanggalPesanan;
  final int totalHarga;

  const CetakPdfTab({
    Key? key,
    required this.selectedPenjualan,
    required this.tanggalPesanan,
    required this.totalHarga,
  }) : super(key: key);

  @override
  State<CetakPdfTab> createState() => _CetakPdfTabState();
}

class _CetakPdfTabState extends State<CetakPdfTab> {
  @override
  void initState() {
    super.initState();
  }

  Future<pw.Document> generatePDF(String PenjualanID) async {
    final pdf = pw.Document();

    try {
      print('Mulai ambil data dari Supabase...');
      
      // Ambil data penjualan dari Supabase
      final responseSales = await Supabase.instance.client
          .from('penjualan')
          .select('*, pelanggan(*)')
          .eq('PenjualanID', PenjualanID)
          .single();
      
      // Cek jika responseSales null atau tidak ada
      if (responseSales == null) {
        print('Error: Data penjualan tidak ditemukan');
        return pdf;
      } else {
        print('Data penjualan berhasil diambil: ${responseSales['PenjualanID']}');
      }

      final responseSalesDetail = await Supabase.instance.client
          .from('detailpenjualan')
          .select('*, produk(*)')
          .eq('PenjualanID', int.parse(PenjualanID));

      // Cek jika responseSalesDetail null atau tidak ada
      if (responseSalesDetail == null || responseSalesDetail.isEmpty) {
        print('Error: Data detail penjualan tidak ditemukan');
        return pdf;
      } else {
        print('Data detail penjualan berhasil diambil, total produk: ${responseSalesDetail.length}');
      }

      // Membuat halaman PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a6, // Ukuran lebih kecil seperti struk
          build: (pw.Context context) {
            print('Membangun halaman PDF...');
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Judul Struk
                pw.Center(
                  child: pw.Text(
                    "Struk Pembelian",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),

                // Info Pelanggan dan Tanggal
                pw.Text("Pelanggan: ${responseSales['pelanggan']['NamaPelanggan']}", style: pw.TextStyle(fontSize: 12)),
                pw.Text("Tanggal: ${responseSales['TanggalPenjualan']}", style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),

                // Garis pemisah
                pw.Divider(),
                pw.SizedBox(height: 5),

                // Tabel detail penjualan (produk, jumlah, subtotal)
                pw.Text("Produk:", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Column(
                  children: List.generate(responseSalesDetail.length, (index) {
                    final detail = responseSalesDetail[index];
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(detail['produk']['NamaProduk'], style: pw.TextStyle(fontSize: 12)),
                        pw.Text("${detail['JumlahProduk']} x ${detail['Subtotal']}", style: pw.TextStyle(fontSize: 12)),
                      ],
                    );
                  }),
                ),
                pw.SizedBox(height: 10),

                // Garis pemisah
                pw.Divider(),
                pw.SizedBox(height: 5),

                // Total Harga
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total Harga:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("${responseSales['TotalHarga']}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Footer / Informasi tambahan
                pw.Center(
                  child: pw.Text("Terima Kasih atas pembelian Anda", style: pw.TextStyle(fontSize: 10)),
                ),
              ],
            );
          },
        ),
      );

      print('PDF berhasil dibangun');
      
    } catch (e) {
      print("Error saat membuat PDF: $e");
    }

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak PDF'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Pilih PenjualanID pertama untuk diambil dari selectedPenjualan
            final PenjualanID = widget.selectedPenjualan[0]['PenjualanID'].toString();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Preview Struk Pembelian'),
                  content: FutureBuilder<pw.Document>(
                    future: generatePDF(PenjualanID),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final pdf = snapshot.data;
                        // Pastikan snapshot.data ada dan bukan null
                        if (pdf != null) {
                          return PdfPreview(
                            build: (format) async => pdf.save(),
                          );
                        } else {
                          return const Center(child: Text('Data tidak ditemukan.'));
                        }
                      } else {
                        return const Center(child: Text('Data tidak ditemukan.'));
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Tutup'),
                    ),
                    
                  ],
                );
              },
            );
          },
          child: const Text('Tampilkan Struk PDF'),
        ),
      ),
    );
  }
}
