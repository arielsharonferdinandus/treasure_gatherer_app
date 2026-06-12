import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Mengimport login page untuk jalan balik

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// PERBAIKAN: Menggunakan _RegisterPageState, bukan _LoginPageState
class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Validasi Gagal", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> _getRegisteredUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('registered_users');
    if (usersJson != null) {
      return jsonDecode(usersJson);
    }
    return [];
  }

  void _register() async {
    String password = _passwordController.text;

    final hasUppercase = RegExp(r'[A-Z]');
    final hasLowercase = RegExp(r'[a-z]');
    final hasDigits = RegExp(r'[0-9]');
    final hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    String errorMessage = "";
    if (password.length < 8) {
      errorMessage = "Password harus terdiri dari minimal 8 karakter.";
    } else if (!hasUppercase.hasMatch(password)) {
      errorMessage = "Password harus mengandung minimal satu huruf kapital (A-Z).";
    } else if (!hasLowercase.hasMatch(password)) {
      errorMessage = "Password harus mengandung minimal satu huruf kecil (a-z).";
    } else if (!hasDigits.hasMatch(password)) {
      errorMessage = "Password harus mengandung minimal satu angka (0-9).";
    } else if (!hasSpecialCharacters.hasMatch(password)) {
      errorMessage = "Password harus mengandung minimal satu simbol atau karakter spesial.";
    }

    if (errorMessage.isNotEmpty) {
      _showErrorDialog(errorMessage);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    List<dynamic> usersList = await _getRegisteredUsers();
    String inputUsername = _usernameController.text.trim();
    String inputEmail = _emailController.text.trim().toLowerCase();
    String formattedPhone = "+62${_phoneController.text.trim()}";

    bool isUsernameTaken = usersList.any((user) => user['username'].toString().toLowerCase() == inputUsername.toLowerCase());
    if (isUsernameTaken) {
      _showErrorDialog("Username sudah terdaftar. Silakan gunakan username lain.");
      return;
    }

    Map<String, String> newUser = {
      "username": inputUsername,
      "email": inputEmail,
      "phone": formattedPhone,
      "password": password,
    };

    usersList.add(newUser);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_users', jsonEncode(usersList));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pendaftaran Berhasil. Silakan Login.")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Buat Akun Anda",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? "Username tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Email tidak boleh kosong";
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(val.trim())) return "Masukkan format email yang valid";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  border: OutlineInputBorder(),
                  prefixText: '+62 ',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '8xxxxxxxx',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Nomor HP tidak boleh kosong";
                  if (!val.startsWith('8')) return "Nomor harus dimulai dengan angka 8";
                  if (val.length < 9 || val.length > 12) return "Harus 9-12 angka setelah +62";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Password tidak boleh kosong";
                  return null;
                },
              ),
              const SizedBox(height: 6),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Petunjuk Keamanan Password:\n- Minimal 8 karakter\n- Kombinasi huruf besar dan kecil (A-z)\n- Harus mengandung Angka (0-9)\n- Harus mengandung Simbol (contoh: @, #, \$, !, %, *)",
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _retypePasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Ulangi Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_clock_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Konfirmasi password tidak boleh kosong";
                  if (val != _passwordController.text) return "Password tidak cocok";
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _register,
                child: const Text("Daftar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              
              // PERBAIKAN NAVIGASI AMAN: Menambahkan opsi balik ke Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke LoginPage dengan aman
                    },
                    child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
