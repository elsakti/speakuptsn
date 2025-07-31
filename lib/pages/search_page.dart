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
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search Twitter',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          style: GoogleFonts.inter(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromRGBO(134, 0, 146, 1)),
      ),
      body: showResults
          ? ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final user = _results[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['avatar']!),
                  ),
                  title: Text(
                    user['name']!,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['username']!,
                        style: TextStyle(
                          color: const Color.fromRGBO(134, 0, 146, 1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(user['tweet']!),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            )
          : Center(
              child: Text(
                'Search for people or tweets',
                style: GoogleFonts.inter(color: Colors.grey[600]),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
