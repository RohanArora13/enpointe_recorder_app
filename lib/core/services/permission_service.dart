import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Request storage permissions at app startup
  static Future<bool> requestStoragePermissions() async {
    try {
      // Check if permissions are already granted
      final storageStatus = await Permission.storage.status;
      final manageExternalStorageStatus = await Permission.manageExternalStorage.status;

      if (storageStatus.isGranted && manageExternalStorageStatus.isGranted) {
        debugPrint('PermissionService: All storage permissions already granted');
        return true;
      }

      // Request permissions with retry logic
      return await _requestPermissionsWithRetry();
    } catch (e) {
      debugPrint('PermissionService: Error requesting permissions: $e');
      return false;
    }
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      // Check if permission is already granted
      final microphoneStatus = await Permission.microphone.status;

      if (microphoneStatus.isGranted) {
        debugPrint('PermissionService: Microphone permission already granted');
        return true;
      }

      // Request microphone permission with retry logic
      return await _requestMicrophonePermissionWithRetry();
    } catch (e) {
      debugPrint('PermissionService: Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Request permissions with retry mechanism
  static Future<bool> _requestPermissionsWithRetry() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('PermissionService: Requesting permissions (attempt $attempt/$_maxRetries)');

        // Request both permissions
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();

        final storageGranted = statuses[Permission.storage]?.isGranted ?? false;
        final manageExternalStorageGranted = statuses[Permission.manageExternalStorage]?.isGranted ?? false;

        if (storageGranted && manageExternalStorageGranted) {
          debugPrint('PermissionService: All permissions granted successfully');
          return true;
        }

        // Check for permanently denied permissions
        final storageDenied = statuses[Permission.storage]?.isPermanentlyDenied ?? false;
        final manageExternalStorageDenied = statuses[Permission.manageExternalStorage]?.isPermanentlyDenied ?? false;

        if (storageDenied || manageExternalStorageDenied) {
          debugPrint('PermissionService: Permissions permanently denied');
          _showPermissionDeniedError();
          return false;
        }

        // If not the last attempt, wait before retrying
        if (attempt < _maxRetries) {
          debugPrint('PermissionService: Retrying in ${_retryDelay.inSeconds} seconds...');
          await Future.delayed(_retryDelay);
        }

      } catch (e) {
        debugPrint('PermissionService: Error on attempt $attempt: $e');
        
        if (attempt == _maxRetries) {
          _showPermissionError('Failed to request permissions after $attempt attempts: $e');
          return false;
        }
        
        // Wait before retrying
        await Future.delayed(_retryDelay);
      }
    }

    debugPrint('PermissionService: Failed to get permissions after $_maxRetries attempts');
    _showPermissionError('Failed to obtain storage permissions after $_maxRetries attempts');
    return false;
  }

  /// Request microphone permission with retry mechanism
  static Future<bool> _requestMicrophonePermissionWithRetry() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('PermissionService: Requesting microphone permission (attempt $attempt/$_maxRetries)');

        // Request microphone permission
        final PermissionStatus status = await Permission.microphone.request();

        if (status.isGranted) {
          debugPrint('PermissionService: Microphone permission granted successfully');
          return true;
        }

        // Check for permanently denied permission
        if (status.isPermanentlyDenied) {
          debugPrint('PermissionService: Microphone permission permanently denied');
          _showMicrophonePermissionDeniedError();
          return false;
        }

        // If not the last attempt, wait before retrying
        if (attempt < _maxRetries) {
          debugPrint('PermissionService: Retrying microphone permission in ${_retryDelay.inSeconds} seconds...');
          await Future.delayed(_retryDelay);
        }

      } catch (e) {
        debugPrint('PermissionService: Error on microphone permission attempt $attempt: $e');
        
        if (attempt == _maxRetries) {
          _showPermissionError('Failed to request microphone permission after $attempt attempts: $e');
          return false;
        }
        
        // Wait before retrying
        await Future.delayed(_retryDelay);
      }
    }

    debugPrint('PermissionService: Failed to get microphone permission after $_maxRetries attempts');
    _showPermissionError('Failed to obtain microphone permission after $_maxRetries attempts');
    return false;
  }

  /// Check current permission status
  static Future<PermissionStatus> getStoragePermissionStatus() async {
    return await Permission.storage.status;
  }

  /// Check current manage external storage permission status
  static Future<PermissionStatus> getManageExternalStoragePermissionStatus() async {
    return await Permission.manageExternalStorage.status;
  }

  /// Check current microphone permission status
  static Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return await Permission.microphone.status;
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    final storageStatus = await Permission.storage.status;
    final manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    
    return storageStatus.isGranted && manageExternalStorageStatus.isGranted;
  }

  /// Check if all required permissions including microphone are granted
  static Future<bool> areAllPermissionsIncludingMicrophoneGranted() async {
    final storageStatus = await Permission.storage.status;
    final manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    final microphoneStatus = await Permission.microphone.status;
    
    return storageStatus.isGranted && manageExternalStorageStatus.isGranted && microphoneStatus.isGranted;
  }

  /// Open app settings for manual permission grant
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('PermissionService: Error opening app settings: $e');
      return false;
    }
  }

  /// Show error message for permission denial
  static void _showPermissionDeniedError() {
    debugPrint('PermissionService: Storage permissions are required for the app to function properly. Please grant permissions in app settings.');
  }

  /// Show error message for microphone permission denial
  static void _showMicrophonePermissionDeniedError() {
    debugPrint('PermissionService: Microphone permission is required for audio recording. Please grant permission in app settings.');
  }

  /// Show general permission error
  static void _showPermissionError(String message) {
    debugPrint('PermissionService: $message');
  }

  /// Get detailed permission status information
  static Future<Map<String, dynamic>> getPermissionStatusDetails() async {
    final storageStatus = await Permission.storage.status;
    final manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    final microphoneStatus = await Permission.microphone.status;

    return {
      'storage': {
        'status': storageStatus.toString(),
        'isGranted': storageStatus.isGranted,
        'isDenied': storageStatus.isDenied,
        'isPermanentlyDenied': storageStatus.isPermanentlyDenied,
        'isRestricted': storageStatus.isRestricted,
      },
      'manageExternalStorage': {
        'status': manageExternalStorageStatus.toString(),
        'isGranted': manageExternalStorageStatus.isGranted,
        'isDenied': manageExternalStorageStatus.isDenied,
        'isPermanentlyDenied': manageExternalStorageStatus.isPermanentlyDenied,
        'isRestricted': manageExternalStorageStatus.isRestricted,
      },
      'microphone': {
        'status': microphoneStatus.toString(),
        'isGranted': microphoneStatus.isGranted,
        'isDenied': microphoneStatus.isDenied,
        'isPermanentlyDenied': microphoneStatus.isPermanentlyDenied,
        'isRestricted': microphoneStatus.isRestricted,
      },
      'allGranted': storageStatus.isGranted && manageExternalStorageStatus.isGranted,
      'allIncludingMicrophoneGranted': storageStatus.isGranted && manageExternalStorageStatus.isGranted && microphoneStatus.isGranted,
    };
  }

  /// Request permissions with custom retry count
  static Future<bool> requestPermissionsWithCustomRetry(int maxRetries) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('PermissionService: Custom retry - Requesting permissions (attempt $attempt/$maxRetries)');

        final Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();

        final storageGranted = statuses[Permission.storage]?.isGranted ?? false;
        final manageExternalStorageGranted = statuses[Permission.manageExternalStorage]?.isGranted ?? false;

        if (storageGranted && manageExternalStorageGranted) {
          debugPrint('PermissionService: All permissions granted successfully');
          return true;
        }

        if (attempt < maxRetries) {
          await Future.delayed(_retryDelay);
        }

      } catch (e) {
        debugPrint('PermissionService: Custom retry error on attempt $attempt: $e');
        if (attempt < maxRetries) {
          await Future.delayed(_retryDelay);
        }
      }
    }

    return false;
  }

  /// Request all permissions including microphone
  static Future<bool> requestAllPermissions() async {
    try {
      // Request storage permissions first
      final storagePermissionsGranted = await requestStoragePermissions();
      
      // Request microphone permission
      final microphonePermissionGranted = await requestMicrophonePermission();
      
      return storagePermissionsGranted && microphonePermissionGranted;
    } catch (e) {
      debugPrint('PermissionService: Error requesting all permissions including microphone: $e');
      return false;
    }
  }
}