import 'package:flutter/material.dart';
import 'upload_report_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        "name": "Martha Craig",
        "handle": "@craig_love",
        "time": "12h",
        "content":
            "Smoking on school grounds harms others and breaks the rules. Let’s remind each other and keep our school safe. 🙏\n#SmokeFreeSchool #StayHealthy",
        "comments": "28",
      },
      {
        "name": "Maximilian",
        "handle": "@maxjacobson",
        "time": "3h",
        "content":
            "Whether it's physical, verbal, or online bullying is violence. Silence only helps the bully.",
        "comments": "46",
      },
      {
        "name": "Tabitha Potter",
        "handle": "@mis_potter",
        "time": "14h",
        "content":
            "Secondhand smoke can severely impact students' developing lungs. Don’t ignore it—speak up and report it.\n#CleanEnvironment #StudentSafety",
        "comments": "7",
      },
      {
        "name": "karenne",
        "handle": "@karennne",
        "time": "10h",
        "content":
            "A safe school starts with you.\nReport smoking. Report bullying.\nBe the voice for change. 📣\nTogether, we create a better space.\n#ReportToProtect #StudentVoices",
        "comments": "1.9K",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/tsn.jpg', // ganti dengan path gambar Anda
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: report['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text:
                                    " ${report['handle']} · ${report['time']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(134, 0, 146, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(report['content'] ?? ''),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.comment,
                              size: 16,
                              color: Color.fromRGBO(134, 0, 146, 1),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              report['comments'].toString(),
                              style: const TextStyle(
                                color: Color.fromRGBO(134, 0, 146, 1),
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
        unselectedItemColor: Color.fromRGBO(134, 0, 146, 1),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Coming Soon',
          ),
        ],
      ),
    );
  }
}
