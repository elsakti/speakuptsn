import 'package:flutter/material.dart';
import 'upload_report_page.dart';
import 'search_page.dart';
import '../widgets/logout_button.dart';
import '../widgets/coin_display.dart';
import '../services/coin_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CoinService _coinService = CoinService();
  int _userCoins = 0; // Will be loaded from Firestore
  bool _isLoadingCoins = true;

  @override
  void initState() {
    super.initState();
    _loadUserCoins();
  }

  Future<void> _loadUserCoins() async {
    try {
      final coins = await _coinService.getCurrentUserCoins();
      print('Loaded coins: $coins'); // Debug log
      if (mounted) {
        setState(() {
          _userCoins = coins > 0 ? coins : 200; // Fallback untuk testing
          _isLoadingCoins = false;
        });
      }
    } catch (e) {
      print('Error loading coins: $e');
      if (mounted) {
        setState(() {
          _userCoins = 200; // Fallback jika error
          _isLoadingCoins = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        "name": "Martha Craig",
        "handle": "",
        "time": "12h",
        "content":
            "Smoking on school grounds harms others and breaks the rules. Let’s remind each other and keep our school safe. 🙏\n#SmokeFreeSchool #StayHealthy",
        "comments": "28",
      },
      {
        "name": "Maximilian",
        "handle": "",
        "time": "3h",
        "content":
            "Whether it's physical, verbal, or online bullying is violence. Silence only helps the bully.",
        "comments": "46",
      },
      {
        "name": "Tabitha Potter",
        "handle": "",
        "time": "14h",
        "content":
            "Secondhand smoke can severely impact students' developing lungs. Don’t ignore it—speak up and report it.\n#CleanEnvironment #StudentSafety",
        "comments": "7",
      },
      {
        "name": "karenne",
        "handle": "",
        "time": "10h",
        "content":
            "A safe school starts with you.\nReport smoking. Report bullying.\nBe the voice for change. 📣\nTogether, we create a better space.\n#ReportToProtect #StudentVoices",
        "comments": "1.9K",
      },
      {
        "name": "Martha Craig",
        "handle": "",
        "time": "12h",
        "content":
            "Smoking on school grounds harms others and breaks the rules. Let’s remind each other and keep our school safe. 🙏\n#SmokeFreeSchool #StayHealthy",
        "comments": "28",
      },
      {
        "name": "Maximilian",
        "handle": "",
        "time": "3h",
        "content":
            "Whether it's physical, verbal, or online bullying is violence. Silence only helps the bully.",
        "comments": "46",
      },
      {
        "name": "Tabitha Potter",
        "handle": "",
        "time": "14h",
        "content":
            "Secondhand smoke can severely impact students' developing lungs. Don’t ignore it—speak up and report it.\n#CleanEnvironment #StudentSafety",
        "comments": "7",
      },
      {
        "name": "karenne",
        "handle": "",
        "time": "10h",
        "content":
            "A safe school starts with you.\nReport smoking. Report bullying.\nBe the voice for change. 📣\nTogether, we create a better space.\n#ReportToProtect #StudentVoices",
        "comments": "1.9K",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/tsn2.jpg',
          height: 35,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isLoadingCoins 
              ? const SizedBox(
                  width: 50,
                  height: 30,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : CoinDisplay(coins: _userCoins),
        ),
        actions: [LogoutButton(), const SizedBox(width: 8)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: Colors.black12,
            height: 1,
            width: double.infinity,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_circle, size: 55),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                report['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${report['handle']} · ${report['time']}",
                                style: const TextStyle(
                                  color: Color.fromRGBO(134, 0, 146, 1),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report['content'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: Color.fromRGBO(134, 0, 146, 1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                report['comments'].toString(),
                                style: const TextStyle(
                                  color: Color.fromRGBO(134, 0, 146, 1),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadReportPage()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: const Color.fromRGBO(134, 0, 146, 1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // index untuk Home
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
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
