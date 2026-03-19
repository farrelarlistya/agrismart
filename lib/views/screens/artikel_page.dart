import 'package:flutter/material.dart';
import '../widgets/article_card_widget.dart';

class ArtikelPage extends StatelessWidget {
  const ArtikelPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data artikel
    final List<Map<String, dynamic>> articles = [
      {
        'title': 'Cara Menanam Padi yang Efektif',
        'category': 'Pertanian Padi',
        'date': '15 Maret 2024',
        'color': Colors.amber,
        'icon': Icons.grass,
      },
      {
        'title': 'Tips Budidaya Cabai di Musim Hujan',
        'category': 'Sayuran',
        'date': '12 Maret 2024',
        'color': Colors.red,
        'icon': Icons.local_florist,
      },
      {
        'title': 'Manfaat Pupuk Organik untuk Tanaman',
        'category': 'Pupuk & Nutrisi',
        'date': '10 Maret 2024',
        'color': Colors.green,
        'icon': Icons.eco,
      },
      {
        'title': 'Panduan Lengkap Menanam Jagung',
        'category': 'Tanaman Pangan',
        'date': '8 Maret 2024',
        'color': Colors.orange,
        'icon': Icons.agriculture,
      },
      {
        'title': 'Mengatasi Hama Tanaman Secara Alami',
        'category': 'Hama & Penyakit',
        'date': '5 Maret 2024',
        'color': Colors.teal,
        'icon': Icons.bug_report,
      },
      {
        'title': 'Teknik Menanam Tomat di Greenhouse',
        'category': 'Hidroponik',
        'date': '3 Maret 2024',
        'color': Colors.deepOrange,
        'icon': Icons.yard,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Artikel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Artikel & Berita Pertanian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...articles.map(
              (article) => ArticleCardWidget(
                title: article['title'],
                category: article['category'],
                date: article['date'],
                imageColor: article['color'],
                imageIcon: article['icon'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
