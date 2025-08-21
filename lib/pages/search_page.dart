import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> _results = [];

  final List<Map<String, String>> _dummyData = [
    {
      'name': 'Alfi Akmal',
      'username': '@alfiakmal',
      'tweet': 'Sedang belajar Flutter dan Firebase!',
      'avatar': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Tasya Nurhaliza',
      'username': '@tasya',
      'tweet': 'Hari ini cuaca sangat cerah, semangat semua!',
      'avatar': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Raka Pratama',
      'username': '@rakapratama',
      'tweet': 'Coding sambil ngopi memang paling nikmat.',
      'avatar': 'https://i.pravatar.cc/150?img=11',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Optional: focus search bar after a delay on page load
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onSearchChanged(String query) {
    final results = _dummyData.where((user) {
      final lowerQuery = query.toLowerCase();
      return user['name']!.toLowerCase().contains(lowerQuery) ||
          user['username']!.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _results = results;
    });
  }

  // This method can be called externally via GlobalKey
  void focusSearch() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    final showResults = _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromRGBO(134, 0, 146, 1)),
        title: Text(
          "Search",
          style: GoogleFonts.inter(
            color: const Color.fromRGBO(134, 0, 146, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Color.fromRGBO(134, 0, 146, 1),
            ),
            const SizedBox(height: 20),
            Text(
              "Coming Soon!\nเร็วๆ นี้",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(134, 0, 146, 1),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),
            Text(
              "The search feature is still under development"
              "\nฟีเจอร์การค้นหายังอยู่ระหว่างการพัฒนา",
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // index untuk Search
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // Kembali ke Home
          }
        },
        selectedItemColor: const Color.fromRGBO(134, 0, 146, 1),
        unselectedItemColor: const Color.fromRGBO(134, 0, 146, 1),
        items: [
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.dashboard),
                SizedBox(height: 2),
                Text(
                  "Home",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  "หน้าหลัก",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
            label: '', // kosongkan biar tidak dobel
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.search),
                SizedBox(height: 2),
                Text(
                  "Search",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  "ค้นหา",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
            label: '', // kosongkan juga
          ),
        ],
      ),
    );
  }
}
