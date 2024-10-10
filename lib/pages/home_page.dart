import 'package:flutter/material.dart';
import 'package:constituent_app/pages/state_select_page.dart';
import 'package:constituent_app/pages/map_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  final PageController _pageController = PageController(initialPage: 0, keepPage: true);

  int _selectedIndex = 0;
  void _onPageChanged(int index){
    setState(() {
      _selectedIndex = index;
    });
  }


  void _onItemTapped(int selectedIndex) {
    _pageController.jumpToPage(selectedIndex);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          StateSelectPage(onNavigate: (_selectedState) {
            setState(() {
              _selectedIndex = 1;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPage(selectedState : _selectedState),
              )
            );
          }),
          MapPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
                Icons.home,
              ), 
              label: "Config",
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.map,
              ), 
              label: "Map",
          ),
        ]),
    );
  }
}