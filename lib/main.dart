import 'package:flutter/material.dart';
import 'pages/wardrobe_page.dart';
import 'pages/profile_page.dart';
import 'pages/try_on_page.dart';
import 'pages/outfits_page.dart';
import 'pages/stats_page.dart';

void main() => runApp(const WardrobeApp());

class WardrobeApp extends StatelessWidget {
  const WardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '试衣间',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _pages = const [WardrobePage(), TryOnPage(), OutfitsPage(), StatsPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: '衣柜'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '试衣'),
          BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark), label: '搭配'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '统计'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: '形象'),
        ],
      ),
    );
  }
}
