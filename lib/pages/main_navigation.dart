import 'package:flutter/material.dart';
import 'home.dart';
import 'search_page.dart';

enum NavigationIndex { home, search }

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  NavigationIndex _currentIndex = NavigationIndex.home;
  final _searchKey = GlobalKey<SearchPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const Home(), SearchPage(key: _searchKey)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex.index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.index,
        selectedItemColor: const Color.fromRGBO(134, 0, 146, 1),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = NavigationIndex.values[index];
            if (_currentIndex == NavigationIndex.search) {
              _searchKey.currentState?.focusSearch();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
