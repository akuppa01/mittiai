import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnonymousTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? anonymousId = prefs.getString('anonymous_id');
    if (anonymousId == null) {
      anonymousId = 'anonymous_${const Uuid().v4()}';
      await prefs.setString('anonymous_id', anonymousId);
    }
    return anonymousId;
  }

  Future<void> trackAnonymousSession() async {
    String userId = await getAnonymousUserId();
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
    }

    if (deviceId == null) {
      print('Warning: Could not get device ID. Cannot track session accurately.');
      return;
    }

    final DocumentReference userDocRef = _firestore.collection('anonymous_users').doc(userId);
    final CollectionReference userSessionsRef = userDocRef.collection('sessions');

    final QuerySnapshot existingSessions = await userSessionsRef
        .where('deviceId', isEqualTo: deviceId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    final Timestamp now = Timestamp.now();

    if (existingSessions.docs.isNotEmpty) {
      final DocumentReference sessionDocRef = existingSessions.docs.first.reference;
      await sessionDocRef.update({
        'lastLogin': now,
        'appVersion': appVersion,
        'platform': platform,
        'isActive': true,
      });
      print('Updated existing session for anonymous user $userId on device $deviceId');
    } else {
      await userSessionsRef.add({
        'createdAt': now,
        'lastLogin': now,
        'appVersion': appVersion,
        'deviceId': deviceId,
        'platform': platform,
        'isActive': true,
        'loggedOutAt': null,
      });
      print('Created new session for anonymous user $userId on device $deviceId');
    }
  }

  Future<void> trackAnonymousLogout() async {
    String userId = await getAnonymousUserId();
    String? deviceId;

    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      print('Error getting device info: $e');
    }

    if (deviceId == null) {
      print('Warning: Cannot track logout without device ID.');
      return;
    }

    final CollectionReference userSessionsRef =
        _firestore.collection('anonymous_users').doc(userId).collection('sessions');

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
      print('Logged out session for anonymous user $userId on device $deviceId');
    } else {
      print('No active session found for anonymous user $userId on device $deviceId to log out.');
    }
  }
}
