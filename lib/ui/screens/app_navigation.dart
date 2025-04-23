import 'package:flutter/material.dart';
import 'daily_spark_screen.dart';
import 'dairy_screen.dart';


class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DailySparkScreen(),
    DiaryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.9),
            elevation: 10,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.local_fire_department),
                label: 'Disciplines',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Diary',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}