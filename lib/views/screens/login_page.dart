import 'package:flutter/material.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// IMAGE BANNER
            Image.asset(
              "assets/images/login_banner.png",
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20),

            /// TITLE
            const Text(
              "Selamat Datang di AgriSmart!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Yuk, daftar atau masuk sekarang juga dan dapatkan langsung semua fitur dari AgriSmart!",
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 25),

            /// EMAIL FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Masukkan Email atau Nomor Telepon",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// PASSWORD FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Masukkan Kata Sandi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LOGIN BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF4C542),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// FORGOT PASSWORD
            const Text(
              "Lupa Kata Sandi?",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 10),

            /// REGISTER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum punya akun? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Daftar",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// GOOGLE LOGIN
            Column(
              children: [
                const Text("Atau gunakan akun"),
                const SizedBox(height: 10),
                Image.network(
                  "https://developers.google.com/identity/images/g-logo.png",
                  width: 40,
                )
              ],
            ),

            const SizedBox(height: 30)
          ],
        ),
      ),
    );
  }
}