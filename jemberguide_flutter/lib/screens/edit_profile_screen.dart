import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jember_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final provider = Provider.of<JemberProvider>(context, listen: false);
      final user = provider.currentUser;
      if (user != null) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JemberProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF8F4C38).withOpacity(0.1), // PrimaryGreen 10%
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 56,
                  color: Color(0xFF8F4C38),
                ),
              ),
              const SizedBox(height: 12),

              // Username Text
              Text(
                user?.username ?? 'User',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF201A19),
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle Text
              Text(
                'Lengkapi detail informasi akun Anda di bawah ini',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF201A19).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 28),

              // Full Name Field
              TextField(
                key: const Key('fullName_field'),
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
              const SizedBox(height: 16),

              // Email Field
              TextField(
                key: const Key('email_field'),
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
              const SizedBox(height: 36),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('save_profile_button'),
                  onPressed: () async {
                    final fullName = _fullNameController.text;
                    final email = _emailController.text;

                    if (fullName.trim().isEmpty || email.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama dan Email wajib diisi!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    await provider.updateProfile(fullName, email);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.crudMessage ?? 'Profil berhasil diperbarui!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      provider.clearCrudStates();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F4C38), // PrimaryGreen
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
