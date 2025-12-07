import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengembang"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aplikasi Kalkulator Ongkir MVVM",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            
            const Divider(),
            const SizedBox(height: 12),
            
            const Row(
              children: [
                Icon(Icons.person, color: Colors.blueGrey, size: 20),
                SizedBox(width: 8),
                Text(
                  "Nama: Stefanie Aurelia Mercy Agahari",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(Icons.badge, color: Colors.blueGrey, size: 20),
                SizedBox(width: 8),
                Text(
                  "NIM: 0706012310056",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(Icons.school, color: Colors.blueGrey, size: 20),
                SizedBox(width: 8),
                Text(
                  "Mata Kuliah: DEPD",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              "Deskripsi Proyek:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "AFL 3 - Implementasi MVVM pada Aplikasi Kalkulator Ongkir Domestik dan Internasional menggunakan API RajaOngkir DEPD.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            
            const Spacer(),
            
            Center(
              child: Text(
                "© 2025 Stefanie Aurelia Mercy Agahari",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}