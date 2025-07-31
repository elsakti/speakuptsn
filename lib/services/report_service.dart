import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reports';

  Future<List<Report>> getAllReports() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching reports: $e');
      throw Exception('Failed to fetch reports: $e');
    }
  }

  Future<List<Report>> getReportsByStatus(String status) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching reports by status: $e');
      throw Exception('Failed to fetch reports by status: $e');
    }
  }

  Future<Report?> getReportById(String reportId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(reportId)
          .get();

      if (doc.exists) {
        return Report.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching report by ID: $e');
      throw Exception('Failed to fetch report: $e');
    }
  }

  Stream<List<Report>> getReportsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((querySnapshot) => 
            querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList());
  }

  Future<void> createReport(Report report) async {
    try {
      // Get next report ID
      final nextReportId = await _getNextReportId();
      
      // Create report with proper ID
      final reportData = report.toFirestore();
      reportData['report_id'] = nextReportId;
      
      await _firestore.collection(_collection).add(reportData);
    } catch (e) {
      print('Error creating report: $e');
      throw Exception('Failed to create report: $e');
    }
  }

  Future<int> _getNextReportId() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('report_id', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 1;
      }

      final lastReport = Report.fromFirestore(querySnapshot.docs.first);
      return lastReport.reportId + 1;
    } catch (e) {
      print('Error getting next report ID: $e');
      return 1; // Fallback to 1 if error
    }
  }

  Future<List<Report>> getVerifiedReports() async {
    return getReportsByStatus('verified');
  }

  Future<List<Report>> getPendingReports() async {
    return getReportsByStatus('pending');
  }

  Future<void> updateReport(String reportId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(reportId).update(updates);
    } catch (e) {
      print('Error updating report: $e');
      throw Exception('Failed to update report: $e');
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection(_collection).doc(reportId).delete();
    } catch (e) {
      print('Error deleting report: $e');
      throw Exception('Failed to delete report: $e');
    }
  }
}
