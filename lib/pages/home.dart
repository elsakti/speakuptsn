import 'package:flutter/material.dart';
import 'upload_report_basic.dart';
import 'search_page.dart';
import 'comment.dart';
import '../widgets/logout_button.dart';
import '../widgets/coin_display.dart';
import '../services/coin_service.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../models/report.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CoinService _coinService = CoinService();
  final ReportService _reportService = ReportService();
  final UserService _userService = UserService();
  int _userCoins = 0;
  bool _isLoadingCoins = true;
  List<Report> _reports = [];
  bool _isLoadingReports = true;

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Initializes state by loading user coins and user data with reports.
  /*******  85dff1d2-baa9-4ee7-9c88-0d6b216e5f85  *******/
  void initState() {
    super.initState();
    _loadUserCoins();
    _loadUserAndReports();
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

  Future<void> _loadUserAndReports() async {
    try {
      // Load user first
      await _userService.loadCurrentUser();

      List<Report> reports;
      if (_userService.isTeacher) {
        // Teachers see all reports
        reports = await _reportService.getAllReports();
      } else {
        // Students only see verified reports
        reports = await _reportService.getVerifiedReports();
      }

      print(
        'Loaded ${reports.length} reports for ${_userService.isTeacher ? "teacher" : "student"}',
      );
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoadingReports = false;
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
      if (mounted) {
        setState(() {
          _reports = [];
          _isLoadingReports = false;
        });
      }
    }
  }

  Widget _buildReportCard(Report report) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and status
            Row(
              children: [
                const Icon(Icons.account_circle, size: 45, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userService.isStudent
                            ? 'Anonymous Student'
                            : 'Student Report',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        report.getTimeAgo(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(report.status),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              report.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),

            // Image if available
            if (report.photoPath.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  report.photoPath,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Footer with report ID
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentPage(report: report),
                  ),
                );
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.comment_rounded,
                    color: Colors.deepPurple,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '100',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Creates a small badge displaying the status of a report.
  ///
  /// The color of the badge and the icon are determined by the status.
  /// The text is the status itself unless the status is "verified", "pending", or "rejected"
  /// in which case a more descriptive text is used.
  ///
  /// The following table shows the mapping between status and badge properties:
  ///
  /// | Status | Badge Color | Icon | Text |
  /// | --- | --- | --- | --- |
  /// | Verified | Green | Icons.verified | Verified |
  /// | Pending | Orange | Icons.pending | Under Review |
  /// | Rejected | Red | Icons.cancel | Rejected |
  /// | Other | Grey | Icons.help | Status text |
  ///
  /// The size of the badge can be controlled by the parent widget.
  /*******  2014e281-bbbc-4c34-95b5-906033f559c3  *******/
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String displayText;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'verified':
        badgeColor = Colors.green;
        displayText = 'Verified';
        icon = Icons.verified;
        break;
      case 'pending':
        badgeColor = Colors.orange;
        displayText = 'Under Review';
        icon = Icons.pending;
        break;
      case 'rejected':
        badgeColor = Colors.red;
        displayText = 'Rejected';
        icon = Icons.cancel;
        break;
      default:
        badgeColor = Colors.grey;
        displayText = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/tsn2.jpg',
          height: 25,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _userService.isStudent
              ? (_isLoadingCoins
                    ? const SizedBox(
                        width: 60,
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 5),
                          ),
                        ),
                      )
                    : CoinDisplay(coins: _userCoins))
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: Colors.orange.shade700,
                      ), // icon poin
                      const SizedBox(width: 5),
                      Text(
                        '120 pts', // nilai poin bisa diganti sesuai kebutuhan
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
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
      body: _isLoadingReports
      body: _isLoadingReports
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? RefreshIndicator(
              onRefresh: _loadUserAndReports,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No reports available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserAndReports,
              child: ListView.builder(
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return _buildReportCard(report);
                },
              ),
            ),
      floatingActionButton: _userService.isStudent
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadReportBasic(),
                  ),
                );
                // Refresh reports after creating a new one
                if (result == true) {
                  _loadUserAndReports();
                }
              },
              shape: const CircleBorder(),
              backgroundColor: const Color.fromRGBO(134, 0, 146, 1),
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
            )
          : null,
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
