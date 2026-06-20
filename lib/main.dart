/// # Dumpen mobilapp
///
/// Flutter-app för dumpen.se — professionell redesign baserad på
/// webbplatsens ChromeNews-tema. Mörk estetik, Jost-typsnitt,
/// utvalda kategorifärger, tidningsartad layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'screens/categories_screen.dart';
import 'screens/donate_screen.dart';
import 'screens/home_screen.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting('sv_SE', null);
  runApp(const DumpenApp());
}

class DumpenApp extends StatelessWidget {
  const DumpenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _ConsentGate(),
    );
  }

  ThemeData _buildTheme() {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surface,
      primaryColor: AppColors.accentYellow,
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.accentYellow,
        onPrimary: Colors.black,
        secondary: AppColors.accentYellow,
        onSecondary: Colors.black,
        surface: AppColors.surface,
        onSurface: AppColors.foreground,
        error: AppColors.errorRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppColors.foreground,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 1.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.foreground,
        unselectedItemColor: AppColors.foregroundDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.foreground),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.foreground),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.foregroundMuted),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.foreground),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.foreground),
        actionTextColor: AppColors.linkBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.foregroundDark),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      dividerColor: AppColors.border,
      extensions: [
        DumpenThemeExtension(
          surfaceElevated: AppColors.surfaceElevated,
          surfaceLight: AppColors.surfaceLight,
          foregroundDark: AppColors.foregroundDark,
          accentYellow: AppColors.accentYellow,
          accentRed: AppColors.accentRed,
          linkBlue: AppColors.linkBlue,
          borderSubtle: AppColors.borderSubtle,
        ),
      ],
    );
  }
}

/// Custom theme extension för färger som inte finns i standard ColorScheme.
class DumpenThemeExtension extends ThemeExtension<DumpenThemeExtension> {
  final Color surfaceElevated;
  final Color surfaceLight;
  final Color foregroundDark;
  final Color accentYellow;
  final Color accentRed;
  final Color linkBlue;
  final Color borderSubtle;

  DumpenThemeExtension({
    required this.surfaceElevated,
    required this.surfaceLight,
    required this.foregroundDark,
    required this.accentYellow,
    required this.accentRed,
    required this.linkBlue,
    required this.borderSubtle,
  });

  @override
  ThemeExtension<DumpenThemeExtension> copyWith({
    Color? surfaceElevated,
    Color? surfaceLight,
    Color? foregroundDark,
    Color? accentYellow,
    Color? accentRed,
    Color? linkBlue,
    Color? borderSubtle,
  }) {
    return DumpenThemeExtension(
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      foregroundDark: foregroundDark ?? this.foregroundDark,
      accentYellow: accentYellow ?? this.accentYellow,
      accentRed: accentRed ?? this.accentRed,
      linkBlue: linkBlue ?? this.linkBlue,
      borderSubtle: borderSubtle ?? this.borderSubtle,
    );
  }

  @override
  ThemeExtension<DumpenThemeExtension> lerp(
    covariant ThemeExtension<DumpenThemeExtension>? other,
    double t,
  ) {
    if (other is! DumpenThemeExtension) return this;
    return DumpenThemeExtension(
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      foregroundDark: Color.lerp(foregroundDark, other.foregroundDark, t)!,
      accentYellow: Color.lerp(accentYellow, other.accentYellow, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      linkBlue: Color.lerp(linkBlue, other.linkBlue, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
    );
  }
}

/// Kontrollerar att användaren har godkänt att appen visar känsligt innehåll.
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
    if (mounted) {
      setState(() {
        _hasConsent = consent;
        _isChecking = false;
      });
    }
  }

  Future<void> _giveConsent() async {
    await CacheService.setConsent(true);
    if (mounted) setState(() => _hasConsent = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
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
                // Logo
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'DUMPEN',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: AppColors.foreground,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Välkommen till Dumpen',
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    color: AppColors.foreground,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Denna app visar innehåll från dumpen.se. Vissa artiklar '
                  'innehåller personuppgifter om brottsmisstänkta och dömda. '
                  'Genom att fortsätta godkänner du detta.',
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    color: AppColors.foregroundMuted,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _giveConsent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Jag förstår och godkänner'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text(
                      'Avbryt',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: AppColors.foregroundDark,
                        fontSize: 14,
                      ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Hem',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Kategorier',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism_outlined),
                activeIcon: Icon(Icons.volunteer_activism),
                label: 'Stöd',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
