import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final String latestVersion;
  final String releaseNotes;
  final String apkDownloadUrl;
  final bool hasUpdate;

  AppUpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    required this.apkDownloadUrl,
    required this.hasUpdate,
  });
}

class UpdateService {
  static const String currentVersion = 'v1.0.11';
  static const String githubApiUrl = 'https://api.github.com/repos/mixxermannipro/nutrilocal/releases/latest';

  /// Checks GitHub API for the latest published release
  static Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(githubApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestTag = (data['tag_name'] as String?) ?? '';
        final body = (data['body'] as String?) ?? 'Neues Update verfügbar!';
        final assets = (data['assets'] as List?) ?? [];

        String downloadUrl = 'https://github.com/mixxermannipro/nutrilocal/releases/latest';
        for (var asset in assets) {
          if ((asset['name'] as String).endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] ?? downloadUrl;
            break;
          }
        }

        final isNewer = _isVersionNewer(latestTag, currentVersion);
        return AppUpdateInfo(
          latestVersion: latestTag,
          releaseNotes: body,
          apkDownloadUrl: downloadUrl,
          hasUpdate: isNewer,
        );
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
    return null;
  }

  static bool _isVersionNewer(String latest, String current) {
    if (latest.isEmpty) return false;
    final cleanLatest = latest.replaceAll('v', '');
    final cleanCurrent = current.replaceAll('v', '');
    return cleanLatest.compareTo(cleanCurrent) > 0;
  }

  /// Opens the APK download URL in browser or package installer
  static Future<void> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
