/// # Dumpen mobilapp
///
/// Flutter-app som är en gåva till barnrättsrörelsen Dumpen (dumpen.se).
/// Appen läser inlägg direkt från Dumpens WordPress REST API och visar
/// dem i ett mörkt, seriöst gränssnitt.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'constants/app_colors.dart';
import 'screens/categories_screen.dart';
import 'screens/donate_screen.dart';
import 'screens/home_screen.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lås appen till porträttläge för en ren mobilupplevelse.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initiera svenska datumformat för artikeldatum.
  await initializeDateFormatting('sv_SE', null);

  runApp(const DumpenApp());
}

/// Huvudwidget som ansvarar för tema, samtyckesdialog och routing.
class DumpenApp extends StatelessWidget {
  const DumpenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dumpen',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _ConsentGate(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surface,
      primaryColor: AppColors.foreground,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.foreground,
        onPrimary: AppColors.background,
        secondary: AppColors.primaryGreen,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.foreground,
        error: AppColors.errorRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.foreground,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.foreground),
        bodyMedium: TextStyle(color: AppColors.foreground),
        bodySmall: TextStyle(color: AppColors.foreground),
        titleLarge: TextStyle(color: AppColors.foreground),
        titleMedium: TextStyle(color: AppColors.foreground),
        titleSmall: TextStyle(color: AppColors.foreground),
        headlineSmall: TextStyle(color: AppColors.foreground),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(color: AppColors.foreground),
        actionTextColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.grey500),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Kontrollerar att användaren har godkänt att appen visar känsligt innehåll
/// innan huvudgränssnittet visas.
class _ConsentGate extends StatefulWidget {
  const _ConsentGate();

  @override
  State<_ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<_ConsentGate> {
  bool _isChecking = true;
  bool _hasConsent = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final consent = await CacheService.hasConsent();
    setState(() {
      _hasConsent = consent;
      _isChecking = false;
    });
  }

  Future<void> _giveConsent() async {
    await CacheService.setConsent(true);
    setState(() => _hasConsent = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.foreground),
        ),
      );
    }

    if (!_hasConsent) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Välkommen till Dumpen',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Denna app visar innehåll från dumpen.se. Vissa artiklar '
                  'innehåller personuppgifter om brottsmisstänkta och dömda. '
                  'Genom att fortsätta godkänner du detta.',
                  style: TextStyle(
                    color: AppColors.grey300,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _giveConsent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Jag förstår och godkänner',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text(
                      'Avbryt',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const _MainScaffold();
  }
}

/// Huvudgränssnittet med bottom navigation och tre flikar.
class _MainScaffold extends StatefulWidget {
  const _MainScaffold();

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    CategoriesScreen(),
    DonateScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Hem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategorier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Stöd',
          ),
        ],
      ),
    );
  }
}
