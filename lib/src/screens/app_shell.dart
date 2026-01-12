import 'package:bt1/src/screens/home_screen.dart';
import 'package:bt1/src/screens/events_screen.dart';
import 'package:bt1/src/screens/register_screen.dart';
import 'package:bt1/src/services/navigation_service.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    EventsScreen(),
    RegisterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Sử dụng ValueListenableBuilder để lắng nghe sự thay đổi tab toàn cục
    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.selectedTabNotifier,
      builder: (context, selectedIndex, child) {
        return Scaffold(
          body: IndexedStack(
            index: selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.celebration_outlined),
                activeIcon: Icon(Icons.celebration),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.how_to_reg_outlined),
                activeIcon: Icon(Icons.how_to_reg),
                label: 'Register',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: (index) {
              // Cập nhật tab thông qua service
              NavigationService.switchTab(index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.indigo[800],
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
          ),
        );
      },
    );
  }
}
