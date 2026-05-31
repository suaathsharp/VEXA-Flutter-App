import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';
import 'package:flutter_application_1/features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── When Firebase is added, initialize here ────────────────────────────
  try {
    await Firebase.initializeApp();
    print('Firebase successfully initialized!');
  } catch (e) {
    print('Firebase Initialization Error: $e');
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const VexaApp());
}

class VexaApp extends StatelessWidget {
  const VexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Single Source of Truth ─────────────────────────────────────────
        ChangeNotifierProvider<AppDataStore>(
          create: (_) => AppDataStore()..initialize(),
        ),
        // ── Additional providers can be added here as the app grows ────────
        // e.g. ChangeNotifierProvider<ThemeStore>(create: (_) => ThemeStore()),
      ],
      child: MaterialApp(
        title: 'VEXA Fashion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE8365D),
            primary: const Color(0xFFE8365D),
            secondary: const Color(0xFFC8A94E),
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          splashFactory: InkRipple.splashFactory,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
