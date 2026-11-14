import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_state.dart';
import 'theme.dart';
import 'widgets/custom_widgets.dart';
import 'screens/home_screen.dart';
import 'screens/dash_screen.dart';
import 'screens/land_screen.dart';
import 'screens/rot_screen.dart';
import 'screens/cmp_screen.dart';
import 'screens/sea_screen.dart';
import 'screens/why_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const FarmWiseApp());
}

class FarmWiseApp extends StatelessWidget {
  const FarmWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final AppState _appState = AppState();

  final List<String> _tabs = [
    "Home",
    "Dashboard",
    "Land analysis",
    "Rotation advisor",
    "Compare",
    "Seasons",
    "Why this?",
    "Ask FarmWise",
  ];

  @override
  void initState() {
    super.initState();
    _appState.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: _appState.isDarkMode ? AppTheme.darkBg : AppTheme.lightBg,
          elevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 0),
                child: Text(
                  'FarmWise',
                  style: GoogleFonts.bricolageGrotesque(
                    color: _appState.isDarkMode ? AppTheme.darkFg : AppTheme.lightFg,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      bool isSelected = _currentIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: isSelected 
                                ? (_appState.isDarkMode ? AppTheme.darkFg : AppTheme.lightFg)
                                : Colors.transparent,
                            foregroundColor: isSelected 
                                ? (_appState.isDarkMode ? const Color(0xFF10221A) : Colors.white)
                                : (_appState.isDarkMode ? AppTheme.darkMuted : AppTheme.lightMuted),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: () => setState(() => _currentIndex = index),
                          child: Text(_tabs[index], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Theme Toggle Button
              IconButton(
                icon: Icon(_appState.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                  color: _appState.isDarkMode ? Colors.amber : AppTheme.lightFg,
                ),
                onPressed: () => _appState.toggleTheme(),
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(child: _buildScreen(_currentIndex)),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onNavigate: (idx) => setState(() => _currentIndex = idx),
          onScrollToHow: () {},
        );
      case 1:
        return DashScreen(state: _appState);
      case 2:
        return LandScreen(
          state: _appState,
          onNavigateToRot: () => setState(() => _currentIndex = 3),
        );
      case 3:
        return RotScreen(state: _appState);
      case 4:
        return CmpScreen(state: _appState);
      case 5:
        return const SeaScreen();
      case 6:
        return const WhyScreen();
      case 7:
        return ChatScreen(state: _appState);
      default:
        return HomeScreen(
          onNavigate: (idx) => setState(() => _currentIndex = idx),
          onScrollToHow: () {},
        );
    }
  }
}