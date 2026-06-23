import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import '../providers/home_controller.dart';
import '../providers/report_controller.dart';
import 'home_screen.dart';
import 'report_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ReportScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    
    if (index == 0) {
      ref.invalidate(journalEntriesProvider);
    } else {
      ref.invalidate(analyticsProvider);
    }
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundWhite,
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: IconThemeData(color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark),
                  unselectedIconTheme: IconThemeData(color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
                  selectedLabelTextStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 16),
                    child: FloatingActionButton(
                      onPressed: () => context.push('/write'),
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 4,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_filled),
                      label: Text("Inicio"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart),
                      label: Text("Reportes"),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            )
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/write'),
              backgroundColor: AppColors.primaryGreen,
              elevation: 8,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
      floatingActionButtonLocation: isWide ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isWide
          ? null
          : BottomAppBar(
              color: isDark ? AppColors.darkSurface : Colors.white,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _onTabTapped(0),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_filled,
                          color: _currentIndex == 0 ? (isDark ? AppColors.secondaryGreen : AppColors.primaryDark) : (isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
                        ),
                        Text(
                          "Inicio", 
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: _currentIndex == 0 ? FontWeight.bold : FontWeight.w500, 
                            color: _currentIndex == 0 ? (isDark ? AppColors.secondaryGreen : AppColors.primaryDark) : (isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)
                          )
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 48),
                  
                  GestureDetector(
                    onTap: () => _onTabTapped(1),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart, 
                          color: _currentIndex == 1 ? (isDark ? AppColors.secondaryGreen : AppColors.primaryDark) : (isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
                        ),
                        Text(
                          "Reportes", 
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: _currentIndex == 1 ? FontWeight.bold : FontWeight.w500, 
                            color: _currentIndex == 1 ? (isDark ? AppColors.secondaryGreen : AppColors.primaryDark) : (isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}