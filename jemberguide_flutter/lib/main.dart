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
import 'screens/presensi_screen.dart';
import 'screens/histori_presensi_screen.dart';
import 'screens/explore_map_screen.dart';
import 'providers/presensi_provider.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const JemberGuideApp());
}

class JemberGuideApp extends StatelessWidget {
  const JemberGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JemberProvider()..loadAllWisata()),
        ChangeNotifierProvider(create: (_) => PresensiProvider()),
      ],
      child: MaterialApp(
        title: 'Jember Guide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF8F4C38),
            onPrimary: Colors.white,
            secondary: Color(0xFFE57E22),
            onSecondary: Colors.white,
            tertiary: Color(0xFFE5A898),
            onTertiary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF201A19),
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
          '/presensi': (context) => const PresensiScreen(),
          '/histori_presensi': (context) => const HistoriPresensiScreen(),
          '/explore_map': (context) => const ExploreMapScreen(),
        },
      ),
    );
  }
}
