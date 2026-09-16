import 'package:blessing_share/core/widgets/app_bottom_navigation.dart';
import 'package:blessing_share/features/catalog/presentation/home_page.dart';
import 'package:blessing_share/features/favorites/favorites_page.dart';
import 'package:blessing_share/features/grid/grid_theme_page.dart';
import 'package:blessing_share/features/profile/profile_page.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(onOpenGrid: _openGrid),
          FavoritesPage(onGoHome: () => _selectTab(0)),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _selectTab,
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openGrid() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GridThemePage()),
    );
  }
}
