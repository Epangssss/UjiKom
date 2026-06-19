import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jemberguide_flutter/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Splash screen visual components smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JemberGuideApp());

    // Verify that the splash screen displays the app title and details
    expect(find.text('JemberGuide'), findsOneWidget);
    expect(find.text('Aplikasi Pencarian Wisata Terbaik di Jember'), findsOneWidget);
    expect(find.byIcon(Icons.landscape), findsOneWidget);

    // Let the splash screen timer expire and complete navigation to avoid pending timers
    await tester.pump(const Duration(milliseconds: 2600));
  });
}
