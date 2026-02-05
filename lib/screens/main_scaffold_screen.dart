import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffoldScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  const MainScaffoldScreen({
    Key? key,
    required this.navigationShell,
    required this.destinations,
  }) : super(key: key);

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: destinations,
      ),
    );
  }
}
