// ──────────────────────────────────────────────────────────────────────────
//  ACTIVITY LOG SERVICE
//  Tracks and logs user operations (Authentication, Cart, Wishlist, Purchases)
//  safely to Cloud Firestore as requested in 'activity_logs' collection.
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter_application_1/data/services/firebase_service.dart';

class ActivityLogService {
  final _firebase = firebaseService;

  /// Logs a user event in firestore collection 'activity_logs'
  Future<void> logActivity({
    required String userId,
    required String activityType,
    Map<String, dynamic>? details,
  }) async {
    try {
      final logData = {
        'userId': userId.isEmpty ? 'guest' : userId,
        'activityType': activityType,
        'details': details ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      print('[ACTIVITY_LOG] Logging activity "$activityType" for user "$userId"');
      await _firebase.activityLogsRef.add(logData).timeout(const Duration(seconds: 4));
      print('[ACTIVITY_LOG] Successfully saved "$activityType" to Firestore');
    } catch (e) {
      print('[ACTIVITY_LOG_ERROR] Failed to write log for "$activityType": $e');
      // Swallowed intentionally so logs don't interrupt primary app functionality.
    }
  }
}

/// Singleton instance accessible project-wide.
final activityLogService = ActivityLogService();
