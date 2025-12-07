// lib/view/pages/main_wrapper.dart
import 'package:depd_mvvm_2025/view/pages/international_page.dart';
import 'package:flutter/material.dart';
import 'package:depd_mvvm_2025/view/pages/pages.dart';
import 'package:depd_mvvm_2025/view/pages/free_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const InternationalPage(),
    const AboutUsPage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Domestik",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: "Internasional",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "Lainnya",
          ),
        ],
      ),
    );
  }
}