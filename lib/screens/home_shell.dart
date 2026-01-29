import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        selectedItemColor: const Color(0xFF1FAAF1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'البروفايل'),
          BottomNavigationBarItem(icon: Icon(Icons.landscape), label: 'سياحه'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسيه'),
        ],
      ),
    );
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
