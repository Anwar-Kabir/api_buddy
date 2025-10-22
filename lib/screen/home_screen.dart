 import 'package:api_buddy/screen/enviroment_scree.dart';
import 'package:api_buddy/screen/history_scree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; 
import 'request_builder_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const RequestBuilderScreen(),
      const HistoryScreen(),
      const EnvironmentScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(PhosphorIcons.checkCircle()),
            icon: Icon(PhosphorIcons.checkCircle()),
            label: 'Request',
          ),
          NavigationDestination(
            selectedIcon: Icon(PhosphorIcons.clockClockwise()),
            icon: Icon(PhosphorIcons.clockClockwise()),
            label: 'History',
          ),
          NavigationDestination(
            selectedIcon: Icon(PhosphorIcons.gear()),
            icon: Icon(PhosphorIcons.gear()),
            label: 'Environment',
          ),
        ],
      ),
    );
  }
}