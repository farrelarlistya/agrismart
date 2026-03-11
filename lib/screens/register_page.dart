import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: const Color(0xFFE8C04A),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Center(
              child: Column(
                children: [
                  Text(
                    "Daftar Akun AgriSmart",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Bergabung dengan marketplace\npertanian terpercaya",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            buildTextField("Nama Lengkap", "Masukkan nama lengkap Anda"),

            buildTextField("Email", "contoh@email.com"),

            buildTextField("Kata Sandi", "Minimal 8 karakter", obscure: true),

            buildTextField("Nomor HP", "08xxxxxxxxxx"),

            buildTextField(
              "Alamat Lengkap",
              "Jalan, Kelurahan, Kecamatan,\nKota/Kabupaten",
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8C04A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Daftar",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Sudah punya akun? ",
                    children: [
                      TextSpan(
                        text: "Masuk",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint,
      {bool obscure = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(label),

          const SizedBox(height: 6),

          TextField(
            obscureText: obscure,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}