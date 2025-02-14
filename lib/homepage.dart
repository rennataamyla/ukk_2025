import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/login.dart';
import 'package:ukk_2025/produk/index.dart';// Pastikan impor ini mengarah ke file yang benar


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: const Text('HomePage'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Produk'),
              Tab(icon: Icon(Icons.people), text: 'Pelanggan'),
              Tab(icon: Icon(Icons.people), text: 'Penjualan'),
              Tab(icon: Icon(Icons.people), text: 'Detail penjualan'),
            ],
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.blue[100],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 142, 162, 178),
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.push(
                    context, 
                   MaterialPageRoute(builder: (context) =>  LoginPage()),
                  );
                }
              )
            ],
          ),
        ),
        body: TabBarView(
          children:[
            ProdukTab(),
            
 
          ] 
        ),
       
      ),
    );
  }
}
