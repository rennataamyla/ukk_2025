import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart'; // Pastikan Anda menggunakan library printing

class CetakPdfTab extends StatefulWidget {
  final Map cetak;
  final String PenjualanID;
  const CetakPdfTab({Key? key, required this.cetak, required this.PenjualanID}) : super(key: key);

  @override
  State<CetakPdfTab> createState() => _CetakPdfTabState();
}

class _CetakPdfTabState extends State<CetakPdfTab> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mencetak PDF saat halaman dimuat
    generateAndPrintPDF(widget.PenjualanID);
  }

  Future<void> generateAndPrintPDF(String PenjualanID) async {
    final pdf = pw.Document();

    // Ambil data penjualan dari Supabase
    final responseSales = await Supabase.instance.client
        .from('penjualan')
        .select('*, pelanggan(*)')
        .eq('PenjualanID', PenjualanID)
        .single();

    final responseSalesDetail = await Supabase.instance.client
        .from('detailpenjualan')
        .select('*, produk(*)')
        .eq('PenjualanID', int.parse(PenjualanID));

    // Pastikan data responseSales dan responseSalesDetail tidak null
    // ignore: unnecessary_null_comparison
    if (responseSalesDetail == null) {
      print('Error: Data tidak ditemukan');
      return;
    }

    // Membuat halaman PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Judul
              pw.Text("Riwayat Transaksi", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
              // Info Pelanggan dan Tanggal
              pw.Text("Pelanggan: ${responseSales['pelanggan']['NamaPelanggan']}", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Tanggal: ${responseSales['TanggalPenjualan']}", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),

              // Tabel detail penjualan
              pw.Table.fromTextArray(
                headers: ["Produk", "Jumlah", "Subtotal"],
                data: List<List<String>>.from(responseSalesDetail.map((detail) {
                  return [
                    detail['produk']['NamaProduk'],
                    detail['JumlahProduk'].toString(),
                    detail['Subtotal'].toString(),
                  ];
                }).toList()),
              ),

              pw.SizedBox(height: 10),

              // Total Harga
              pw.Text("Total Harga: ${responseSales['TotalHarga']}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    // Cetak PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Tidak menampilkan UI, hanya proses cetak PDF
  }
}
