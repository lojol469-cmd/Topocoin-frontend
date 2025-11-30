import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/send_screen.dart';
import 'screens/receive_screen.dart';
import 'screens/biometric_settings_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/language_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // You can customize how logs are handled here
  });
  
  final logger = Logger('TopocoinWallet');
  
  // Initialize Firebase FIRST (required for NotificationService)
  try {
    await Firebase.initializeApp();
    logger.info('Firebase initialized successfully');
  } catch (e) {
    // Firebase not configured, log error but continue
    logger.warning('Firebase initialization failed: $e');
    logger.warning('Notifications will not be available');
  }
  
  // Initialize NotificationService after Firebase
  try {
    await NotificationService().initialize();
  } catch (e) {
    logger.warning('Notification service initialization failed: $e');
  }
  
  runApp(const TopocoinWalletApp());
}

class TopocoinWalletApp extends StatelessWidget {
  const TopocoinWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        title: 'Topocoin Wallet',
        theme: ThemeData(
          primaryColor: const Color(0xFF00D4FF), // Cyan futuristic color
          scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Dark background
          textTheme: GoogleFonts.orbitronTextTheme(
            Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00D4FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00D4FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF00D4FF)),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainNavigation(),
          '/wallet': (context) => const MainNavigation(),
          '/send': (context) => const SendScreen(),
          '/receive': (context) => const ReceiveScreen(),
          '/biometric_settings': (context) => const BiometricSettingsScreen(),
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: languageProvider.getText('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: languageProvider.getText('profile'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: languageProvider.getText('settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00D4FF),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1A1A1A),
        onTap: _onItemTapped,
      ),
    );
  }
}