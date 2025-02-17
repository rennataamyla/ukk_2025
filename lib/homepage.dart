import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/login.dart';
import 'package:ukk_2025/pelanggan/index.dart';
import 'package:ukk_2025/penjualan/index.dart';
import 'package:ukk_2025/produk/index.dart';
import 'package:ukk_2025/user/index.dart';
import 'package:ukk_2025/user/insert.dart'; // Pastikan impor ini mengarah ke file yang benar

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0; // Menyimpan index yang dipilih

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Mengubah index yang dipilih
    });
  }

  void _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 133, 167, 206),
        title: const Text('HomePage'),
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue[100],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 133, 167, 206),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Navigasi Cepat',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
                leading: const Icon(Icons.people_alt_outlined),
                title: const Text('User'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserTab())
                    );
                  
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex, // Mengatur tampilan berdasarkan index yang dipilih
        children: const [
          ProdukTab(),
          penjualanTab(),
          PelangganTab(),
         
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Menunjukkan tab yang sedang dipilih
        onTap: _onItemTapped, // Mengatur perubahan tab
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produk',
            backgroundColor: Color.fromARGB(255, 133, 167, 206),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Transaksi',
            backgroundColor: Color.fromARGB(255, 133, 167, 206),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pelanggan',
             backgroundColor: Color.fromARGB(255, 133, 167, 206),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.details),
            label: 'Riwayat Transaksi',
            backgroundColor: Color.fromARGB(255, 133, 167, 206),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'User',
            backgroundColor: Color.fromARGB(255, 133, 167, 206),
          ),
        ],
      ),
    );
  }
}
