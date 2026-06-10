import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/jember_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/add_edit_wisata_screen.dart';
import 'screens/edit_profile_screen.dart';

void main() {
  runApp(const JemberGuideApp());
}

class JemberGuideApp extends StatelessWidget {
  const JemberGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JemberProvider()..loadAllWisata()),
      ],
      child: MaterialApp(
        title: 'Jember Guide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/detail': (context) => const DetailScreen(),
          '/add_edit_wisata': (context) => const AddEditWisataScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
        },
      ),
    );
  }
}
