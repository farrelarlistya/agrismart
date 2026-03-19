import 'package:agrismart/widgets/text_field_widget.dart';
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
          children: [
            const SizedBox(height: 20),

            const Center(
              child: Column(
                children: [
                  Text(
                    "Daftar Akun AgriSmart",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

            TextFieldWidget(
              label: "Nama Lengkap",
              hint: "Masukkan nama lengkap Anda",
            ),

            TextFieldWidget(
              label: "Email",
              hint: "contoh@email.com",
            ),

            TextFieldWidget(
              label: "Kata Sandi",
              hint: "Minimal 8 karakter",
              obscure: true,
            ),

            TextFieldWidget(
              label: "Nomor HP",
              hint: "08xxxxxxxxxx",
            ),

            TextFieldWidget(
              label: "Alamat Lengkap",
              hint: "Jalan, Kelurahan, Kecamatan,\nKota/Kabupaten",
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
