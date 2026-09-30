import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:harcama_takip_uygulamasi/features/profile/profile_screen.dart';
import 'package:harcama_takip_uygulamasi/features/statistics/statistics_screen.dart';

import 'package:go_router/go_router.dart';

import 'package:harcama_takip_uygulamasi/features/home/home_screen.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/screens/expense_list_screen.dart';
import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ExpenseListScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.brandGradient(context),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.push('/expense-add'),
            child: Icon(
              LucideIcons.plus,
              color: AppTheme.onBrandGradient(context),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface
            .withValues(alpha: 0.5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.house),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.list_ordered),
            label: 'Harcama',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.chart_pie),
            label: 'İstatistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
