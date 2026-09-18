import 'package:blessing_share/core/widgets/app_bottom_navigation.dart';
import 'package:blessing_share/core/widgets/lazy_indexed_stack.dart';
import 'package:blessing_share/features/catalog/presentation/home_page.dart';
import 'package:blessing_share/features/favorites/favorites_page.dart';
import 'package:blessing_share/features/grid/grid_theme_page.dart';
import 'package:blessing_share/features/profile/profile_page.dart';
import 'package:blessing_share/features/update/app_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      body: LazyIndexedStack(
        index: _currentIndex,
        itemCount: 3,
        itemBuilder: (context, index) => switch (index) {
          0 => HomePage(onOpenGrid: _openGrid),
          1 => FavoritesPage(onGoHome: () => _selectTab(0)),
          _ => const ProfilePage(),
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _selectTab,
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      // Check updates whenever user enters “我的”.
      context.read<AppUpdateProvider>().checkForUpdate();
    }
  }

  void _openGrid() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GridThemePage()),
    );
  }
}
