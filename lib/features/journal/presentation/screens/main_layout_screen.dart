import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import '../providers/home_controller.dart';
import '../providers/report_controller.dart';
import 'home_screen.dart';
import 'report_screen.dart';
import 'editor_screen.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const EditorScreen())
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
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
                    color: _currentIndex == 0 ? AppColors.primaryDark : AppColors.textSubtitle,
                  ),
                  Text(
                    "Inicio", 
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: _currentIndex == 0 ? FontWeight.bold : FontWeight.w500, 
                      color: _currentIndex == 0 ? AppColors.primaryDark : AppColors.textSubtitle
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
                    color: _currentIndex == 1 ? AppColors.primaryDark : AppColors.textSubtitle,
                  ),
                  Text(
                    "Reportes", 
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: _currentIndex == 1 ? FontWeight.bold : FontWeight.w500, 
                      color: _currentIndex == 1 ? AppColors.primaryDark : AppColors.textSubtitle
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