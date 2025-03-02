import 'package:flutter/material.dart';
import 'account_list_screen.dart';
import 'info_page.dart';
import 'about_us_screen.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  final List<Widget> _pages = [
    AccountListScreen(),
    InfoPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Animate to the selected page when tapping bottom nav items
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IUST Login Manager',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Color(0xFF0e6a8c),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
            ),
            tooltip: 'About Us',
            onPressed: () {
              // Navigate to About Us Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
        // Optional: Add physics for custom scroll behavior
        physics: const ClampingScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_check),
            label: 'Status',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
