import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final int selectedIndex = _calculateSelectedIndex(context);

    if (width > 600) {
      // Wide Screen: NavigationRail
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Color(0xFF1FAAF1)),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF1FAAF1),
                fontWeight: FontWeight.bold,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('البروفايل'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.landscape),
                  label: Text('سياحه'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('الرئيسيه'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      // Narrow Screen: BottomNavigationBar
      return Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (int idx) => _onItemTapped(idx, context),
          selectedItemColor: const Color(0xFF1FAAF1),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'البروفايل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.landscape),
              label: 'سياحه',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسيه'),
          ],
        ),
      );
    }
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/profile')) return 0;
    if (location.startsWith('/tourist')) return 1;
    // Default or /planner is Home
    return 2;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/profile');
        break;
      case 1:
        context.go('/tourist');
        break;
      case 2:
        context.go('/planner');
        break;
    }
  }
}
