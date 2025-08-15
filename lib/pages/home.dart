import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_report_basic.dart';
import 'search_page.dart';
import 'comment_page.dart';
import '../services/coin_service.dart';
import '../widgets/logout_button.dart';
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
          _userCoins = coins;
          _isLoadingCoins = false;
        });
      }
    } catch (e) {
      print('Error loading coins: $e');
      if (mounted) {
        setState(() {
          _userCoins = 0; // Show 0 if error loading
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
        // Teachers see active reports (pending and verified, not rejected)
        reports = await _reportService.getActiveReports();
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

            // Footer with actions
            Row(
              children: [
                Icon(Icons.assignment, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Report #${report.reportId}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const Spacer(),
                // Accept and Delete buttons for teachers on pending reports
                if (_userService.isTeacher && report.status.toLowerCase() == 'pending') ...[
                  IconButton(
                    onPressed: () => _showAcceptConfirmationDialog(report),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.all(8),
                    ),
                    tooltip: 'Accept Report',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmationDialog(report),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(8),
                    ),
                    tooltip: 'Reject Report',
                  ),
                ],
                // Comment button
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentPage(report: report),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Comments', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                if (_userService.isTeacher &&
                    report.verificationNotes.isNotEmpty) ...[
                  const Icon(
                    Icons.comment_rounded,
                    color: Colors.deepPurple,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '100',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Future<void> _showDeleteConfirmationDialog(Report report) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Report'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to reject Report #${report.reportId}?'),
                const SizedBox(height: 8),
                const Text(
                  'This action will change the status to "Rejected" and remove it from the main feed.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _rejectReport(report);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectReport(Report report) async {
    try {
      await _reportService.rejectReport(report.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        // Refresh the reports list
        _loadUserAndReports();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAcceptConfirmationDialog(Report report) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Report'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to accept Report #${report.reportId}?'),
                const SizedBox(height: 8),
                const Text(
                  'This action will verify the report and you will earn 10 coins.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Accept'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _acceptReport(report);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _acceptReport(Report report) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;
      
      // Verify the report
      await _reportService.verifyReport(report.id, user.uid);
      
      // Add 10 coins to teacher using email
      await _coinService.addCoins(user.email!, 10);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report accepted successfully! You earned 10 coins.'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the reports list and coins
        _loadUserAndReports();
        _loadUserCoins();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        leadingWidth: _userService.isTeacher ? 100 : null,
        leading: _userService.isTeacher
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isLoadingCoins ? '...' : '$_userCoins',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        actions: [LogoutButton(), const SizedBox(width: 4)],
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
