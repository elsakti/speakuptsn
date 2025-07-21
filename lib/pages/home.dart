import 'package:flutter/material.dart';
import 'upload_report_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/tsn.jpg', height: 50),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
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
                    const Icon(Icons.account_circle, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama, handle, dan waktu
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
                          // Konten
                          Text(
                            report['content'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          // Komentar
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
        selectedItemColor: const Color.fromRGBO(134, 0, 146, 1),
        unselectedItemColor: const Color.fromRGBO(134, 0, 146, 1),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
