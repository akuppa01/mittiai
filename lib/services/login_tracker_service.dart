import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io'; // For Platform.isAndroid, Platform.isIOS
// REMOVED: import 'package:firebase_auth/firebase_auth.dart';

class LoginTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // REMOVED: final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track login session for a given userId (phone number) and stores/updates profile data.
  Future<void> trackLoginSession(
    String userId, { // REVERTED: parameter is now userId (phone number)
    String? name,
    String? village,
    String? state,
    String? email,
    String? phoneNumber, // This is expected to be the same as userId
    String? cropType,
    String? languageName,
  }) async {
    // REMOVED: Firebase Auth check
    // if (_auth.currentUser?.uid != authUid) { ... }

    // 1. Store/Update User Profile Data using userId (phone number) as the document ID
    final DocumentReference userDocRef = _firestore.collection('users').doc(userId); // REVERTED
    Map<String, dynamic> userData = {};

    if (name != null && name.isNotEmpty) userData['name'] = name;
    if (village != null && village.isNotEmpty) userData['village'] = village;
    if (state != null && state.isNotEmpty) userData['state'] = state;
    if (email != null && email.isNotEmpty) userData['email'] = email;
    // phoneNumber is a field within the user document (it's the same as userId for path)
    if (phoneNumber != null && phoneNumber.isNotEmpty) userData['phoneNumber'] = phoneNumber; 
    if (cropType != null && cropType.isNotEmpty) userData['cropType'] = cropType;
    if (languageName != null && languageName.isNotEmpty) userData['language'] = languageName;

    // Add a lastUpdated timestamp for the profile data itself
    userData['profileLastUpdated'] = Timestamp.now();

    if (userData.isNotEmpty) {
      await userDocRef.set(userData, SetOptions(merge: true));
      print('User profile data updated for user $userId'); // REVERTED
      // Small delay to account for Firestore eventual consistency, still useful.
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 2. Continue with Login Session Tracking (existing logic, mostly unchanged)
    String? deviceId;
    String? appVersion;
    String? platform;

    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        platform = 'Android';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor;
        platform = 'iOS';
      } else {
        deviceId = 'unknown_device';
        platform = 'Web/Other';
      }

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
    } catch (e) {
      print('Error getting device or package info: $e');
      // Continue without this data if an error occurs
    }

    if (deviceId == null) {
      print('Warning: Could not get device ID. Cannot track session accurately.');
      return;
    }

    final CollectionReference userSessionsRef =
        userDocRef.collection('login_sessions');

    final QuerySnapshot existingSessions = await userSessionsRef
        .where('deviceId', isEqualTo: deviceId)
        .where('isActive', isEqualTo: true) // Look for an active session on this device
        .limit(1)
        .get();

    final Timestamp now = Timestamp.now();

    if (existingSessions.docs.isNotEmpty) {
      final DocumentReference sessionDocRef = existingSessions.docs.first.reference;
      await sessionDocRef.update({
        'lastLogin': now,
        'appVersion': appVersion, // Update app version in case it changed
        'platform': platform,
        'isActive': true, // Ensure it's marked as active
      });
      print('Updated existing login session for user $userId on device $deviceId'); // REVERTED
    } else {
      await userSessionsRef.add({
        'createdAt': now,
        'lastLogin': now,
        'appVersion': appVersion,
        'deviceId': deviceId,
        'platform': platform,
        'isActive': true,
        'loggedOutAt': null, // No logout time initially
      });
      print('Created new login session for user $userId on device $deviceId'); // REVERTED
    }
  }

  // Track logout session for a given userId (phone number) and deviceId
  Future<void> trackLogoutSession(String userId, String deviceId) async { // REVERTED
    if (deviceId == null) {
      print('Warning: Cannot track logout without device ID.');
      return;
    }

    final CollectionReference userSessionsRef =
        _firestore.collection('users').doc(userId).collection('login_sessions'); // REVERTED

    final QuerySnapshot activeSessions = await userSessionsRef
        .where('deviceId', isEqualTo: deviceId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (activeSessions.docs.isNotEmpty) {
      final DocumentReference sessionDocRef = activeSessions.docs.first.reference;
      await sessionDocRef.update({
        'isActive': false,
        'loggedOutAt': Timestamp.now(),
      });
      print('Logged out session for user $userId on device $deviceId'); // REVERTED
    } else {
      print('No active session found for user $userId on device $deviceId to log out.'); // REVERTED
    }
  }

  // Stream to retrieve active sessions
  Stream<List<Map<String, dynamic>>> getActiveSessions(String userId) { // REVERTED
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('login_sessions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'sessionId': doc.id,
              ...doc.data(),
            }).toList());
  }

  // New method to get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async { // REVERTED
    final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get(); // REVERTED
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return null;
  }
}