import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show GlobalKey, NavigatorState;

class ApiConstants {
  static const String emulatorUrl = 'http://10.0.2.2:8001';
  static const String localhostUrl = 'http://localhost:8001';
  static const String localNetworkUrl = 'http://192.168.1.12:8001';
  
  static String get baseUrl {
    if (kIsWeb) {
      return localNetworkUrl;
    }
    if (Platform.isAndroid) {
      return localNetworkUrl;
    }
    return localNetworkUrl;
  }
  
  static const String apiVersion = '/';
  
  static const String getUser = '/user/{user_id}';
  static const String updateUser = '/user/{user_id}';
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String getAppliances = '/appliances/{user_id}';
  static const String createAppliance = '/appliances/{user_id}';
  static const String deleteAppliance = '/appliances/{appliance_id}';
  static const String getUsageLogs = '/usage/{user_id}';
  static const String createUsageLog = '/usage/{user_id}';
  static const String getAnalytics = '/analytics/{user_id}';
  static const String getEcoTips = '/analytics/tips/list';
  static const String healthCheck = '/health';
  static const String calculateCarbon = '/calculate';
}

class AppConstants {
  static const int defaultUserId = 1;
  static const double emissionFactor = 0.82;
  static const String appName = 'Eco Warrior';
  static const String appTagline = 'Track Your Carbon Footprint';
  static final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
}
