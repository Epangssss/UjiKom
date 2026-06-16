import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/jember_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showVerificationDialog(
    String username,
    String password,
    String fullName,
    String email,
    JemberProvider provider,
  ) {
    // Generate a random 4-digit code
    final generatedCode = (Random().nextInt(9000) + 1000).toString();
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Verifikasi Keamanan Gmail',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simulasi kode keamanan telah dikirim ke $email.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Masukkan kode: '),
                  Text(
                    generatedCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFFE57E22), // SecondaryAmber
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Kode Keamanan',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                otpController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (otpController.text.trim() == generatedCode) {
                  otpController.dispose();
                  Navigator.pop(dialogContext); // close dialog
                  
                  // Proceed with registration
                  _executeSignUp(username, password, fullName, email, provider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kode Keamanan salah! Silakan coba lagi.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Verifikasi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeSignUp(
    String username,
    String password,
    String fullName,
    String email,
    JemberProvider provider,
  ) async {
    setState(() => _isLoading = true);
    await provider.signUp(username, password, fullName, email);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (provider.authError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.authError!),
          duration: const Duration(seconds: 2),
        ),
      );
      provider.clearAuthStates();
    } else if (provider.registrationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          duration: Duration(seconds: 3),
        ),
      );
      provider.clearAuthStates();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JemberProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Daftar Akun Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Buat Akun Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lengkapi data diri untuk memulai petualangan di Jember',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Username input
              TextField(
                key: const Key('reg_username_input'),
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password input
              TextField(
                key: const Key('reg_password_input'),
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nama Lengkap input
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Email input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register button
              ElevatedButton(
                key: const Key('register_button'),
                onPressed: _isLoading
                    ? null
                    : () {
                        final username = _usernameController.text;
                        final password = _passwordController.text;
                        final fullName = _fullNameController.text;
                        final email = _emailController.text;

                        if (username.trim().isEmpty ||
                            password.trim().isEmpty ||
                            fullName.trim().isEmpty ||
                            email.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua kolom wajib diisi'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        // Gmail validation check
                        if (email.trim().toLowerCase().endsWith('@gmail.com')) {
                          _showVerificationDialog(
                            username,
                            password,
                            fullName,
                            email,
                            provider,
                          );
                        } else {
                          _executeSignUp(
                            username,
                            password,
                            fullName,
                            email,
                            provider,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF8F4C38), // PrimaryGreen
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Daftar Akun',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
