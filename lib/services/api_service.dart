import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/appliance_model.dart';
import '../models/usage_log_model.dart';
import '../models/analytics_model.dart';
import '../models/eco_tip_model.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  bool useMockData;

  ApiService({String? baseUrl, http.Client? client, this.useMockData = false})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _client = client ?? http.Client();

  Future<void> checkAndUseOfflineMode() async {
    final isConnected = await checkServerConnection();
    useMockData = !isConnected;
    debugPrint('[ApiService] Server connected: $isConnected, using mock data: $useMockData');
  }

  void printDebug(String message) {
    debugPrint('[ApiService] $message');
  }

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<bool> checkServerConnection() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel> getUser(int userId) async {
    if (useMockData) {
      printDebug('Using mock data for getUser');
      return _getMockUser(userId);
    }
    try {
      printDebug('getUser called for userId=$userId, url=$baseUrl/user/$userId');
      final response = await _client.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      printDebug('getUser response status=${response.statusCode}');
      
      if (response.statusCode == 200) {
        printDebug('getUser success');
        return UserModel.fromJson(json.decode(response.body));
      } else {
        printDebug('getUser error - ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      printDebug('getUser exception - $e');
      rethrow;
    }
  }

  UserModel _getMockUser(int userId) {
    final userLogs = _mockUsageLogs.where((log) => log.userId == userId).toList();
    final totalEmissions = userLogs.fold<double>(0, (sum, log) => sum + log.carbonEmission);
    
    return UserModel(
      id: userId,
      username: 'eco_warrior',
      role: 'user',
      memberSince: DateTime.now().toIso8601String().split('T')[0],
      totalCarbonEmissions: totalEmissions,
      darkMode: false,
      ecoTipsNotifications: true,
    );
  }

  Future<UserModel> updateUser(int userId, Map<String, dynamic> updates) async {
    if (useMockData) {
      return _getMockUser(userId);
    }
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/user/$userId'),
        headers: await _getHeaders(),
        body: json.encode(updates),
      );
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  int _mockApplianceIdCounter = 4;
  final List<ApplianceModel> _mockAppliances = [];
  int _mockLogIdCounter = 1;
  final List<UsageLogModel> _mockUsageLogs = [];

  Future<List<ApplianceModel>> getAppliances(int userId) async {
    if (useMockData) {
      return _getMockAppliances(userId);
    }
    try {
      debugPrint('API: getAppliances called for userId=$userId, url=$baseUrl/appliances/$userId');
      final response = await _client.get(
        Uri.parse('$baseUrl/appliances/$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      debugPrint('API: getAppliances response status=${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('API: getAppliances success - ${data.length} appliances');
        return data.map((e) => ApplianceModel.fromJson(e)).toList();
      } else {
        debugPrint('API: getAppliances error - ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load appliances: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API: getAppliances exception - $e');
      throw Exception('Failed to load appliances: $e');
    }
  }

  List<ApplianceModel> _getMockAppliances(int userId) {
    return List.from(_mockAppliances);
  }

  Future<ApplianceModel> createAppliance(int userId, ApplianceCreate appliance) async {
    if (useMockData) {
      final newAppliance = ApplianceModel(
        id: _mockApplianceIdCounter,
        userId: userId,
        name: appliance.name,
        applianceType: appliance.applianceType,
        wattage: appliance.wattage,
        quantity: appliance.quantity,
        createdAt: DateTime.now().toIso8601String(),
      );
      _mockAppliances.add(newAppliance);
      _mockApplianceIdCounter++;
      return newAppliance;
    }
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/appliances/$userId'),
        headers: await _getHeaders(),
        body: json.encode(appliance.toJson()),
      );
      
      if (response.statusCode == 200) {
        return ApplianceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create appliance: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create appliance: $e');
    }
  }

  Future<void> deleteAppliance(int applianceId) async {
    if (useMockData) {
      _mockAppliances.removeWhere((a) => a.id == applianceId);
      return;
    }
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/appliances/$applianceId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete appliance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete appliance: $e');
    }
  }

  Future<List<UsageLogModel>> getUsageLogs(int userId, {int? limit}) async {
    if (useMockData) {
      return _getMockUsageLogs(userId, limit: limit);
    }
    try {
      String url = '$baseUrl/usage/$userId';
      if (limit != null) {
        url += '?limit=$limit';
      }
      debugPrint('API: Fetching usage logs from $url');
      
      final response = await _client.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      debugPrint('API: Usage logs response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('API: ${data.length} usage logs received');
        return data.map((e) => UsageLogModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load usage logs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API: Usage logs exception - $e');
      throw Exception('Failed to load usage logs: $e');
    }
  }

  List<UsageLogModel> _getMockUsageLogs(int userId, {int? limit}) {
    final logs = List<UsageLogModel>.from(_mockUsageLogs);
    
    if (limit != null) {
      return logs.take(limit).toList();
    }
    return logs;
  }

  Future<UsageLogModel> createUsageLog(int userId, UsageLogCreate log) async {
    if (useMockData) {
      final appliance = _mockAppliances.firstWhere(
        (a) => a.id == log.applianceId,
        orElse: () => ApplianceModel(
          id: log.applianceId,
          userId: userId,
          name: 'Unknown',
          applianceType: 'Unknown',
          wattage: 100,
          quantity: 1,
          createdAt: '',
        ),
      );
      final emission = _calculateMockEmission(appliance, log.hours);
      final newLog = UsageLogModel(
        id: _mockLogIdCounter,
        userId: userId,
        applianceId: log.applianceId,
        hours: log.hours,
        date: log.date,
        carbonEmission: emission,
        createdAt: DateTime.now().toIso8601String(),
      );
      _mockUsageLogs.add(newLog);
      _mockLogIdCounter++;
      return newLog;
    }
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/usage/$userId'),
        headers: await _getHeaders(),
        body: json.encode(log.toJson()),
      );
      
      if (response.statusCode == 200) {
        return UsageLogModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create usage log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create usage log: $e');
    }
  }

  double _calculateMockEmission(ApplianceModel appliance, double hours) {
    return (appliance.wattage * hours / 1000) * 0.82 * appliance.quantity;
  }

  Future<AnalyticsModel> getAnalytics(int userId) async {
    if (useMockData) {
      printDebug('Using mock data for getAnalytics');
      return _getMockAnalytics(userId);
    }
    try {
      printDebug('Fetching analytics for user $userId from $baseUrl/analytics/$userId');
      final response = await _client.get(
        Uri.parse('$baseUrl/analytics/$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      printDebug('Analytics response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        printDebug('Analytics data received successfully');
        return AnalyticsModel.fromJson(json.decode(response.body));
      } else {
        printDebug('Analytics error - ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } on Exception catch (e) {
      printDebug('Analytics exception - $e');
      rethrow;
    }
  }

  AnalyticsModel _getMockAnalytics(int userId) {
    final logs = _mockUsageLogs.where((log) => log.userId == userId).toList();
    
    if (logs.isEmpty) {
      return AnalyticsModel(
        dailyEmissions: [],
        weeklyTotal: 0,
        monthlyTotal: 0,
        yearlyTotal: 0,
        monthlyEmissions: [],
        emissionsByAppliance: [],
        topAppliances: [],
        highestEmissionAppliance: null,
        todayEmission: 0,
        dailyAverage: 0,
        totalCarbonEmissions: 0,
      );
    }
    
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));
    final yearAgo = now.subtract(const Duration(days: 365));
    
    final todayLogs = logs.where((l) => l.date == today).toList();
    final weekLogs = logs.where((l) => DateTime.parse(l.date).isAfter(weekAgo)).toList();
    final monthLogs = logs.where((l) => DateTime.parse(l.date).isAfter(monthAgo)).toList();
    final yearLogs = logs.where((l) => DateTime.parse(l.date).isAfter(yearAgo)).toList();
    
    final todayEmission = todayLogs.fold<double>(0, (sum, log) => sum + log.carbonEmission);
    final weeklyTotal = weekLogs.fold<double>(0, (sum, log) => sum + log.carbonEmission);
    final monthlyTotal = monthLogs.fold<double>(0, (sum, log) => sum + log.carbonEmission);
    final yearlyTotal = yearLogs.fold<double>(0, (sum, log) => sum + log.carbonEmission);
    
    final Map<String, double> emissionsByType = {};
    for (final log in logs) {
      final appliance = _mockAppliances.firstWhere(
        (a) => a.id == log.applianceId,
        orElse: () => ApplianceModel(id: 0, userId: userId, name: 'Unknown', applianceType: 'Unknown', wattage: 0, quantity: 1, createdAt: ''),
      );
      emissionsByType[appliance.name] = (emissionsByType[appliance.name] ?? 0) + log.carbonEmission;
    }
    
    final emissionsByAppliance = emissionsByType.entries.map((e) {
      final appliance = _mockAppliances.firstWhere((a) => a.name == e.key, orElse: () => _mockAppliances.first);
      return ApplianceEmission(
        name: e.key,
        type: appliance.applianceType,
        emission: e.value,
        quantity: appliance.quantity,
      );
    }).toList();
    
    emissionsByAppliance.sort((a, b) => b.emission.compareTo(a.emission));
    
    final highestEmissionAppliance = emissionsByAppliance.isNotEmpty ? emissionsByAppliance.first : null;
    
    final Map<String, double> dailyMap = {};
    for (final log in weekLogs) {
      dailyMap[log.date] = (dailyMap[log.date] ?? 0) + log.carbonEmission;
    }
    
    final dailyEmissions = <DailyEmission>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      dailyEmissions.add(DailyEmission(
        date: dateStr,
        emission: dailyMap[dateStr] ?? 0,
      ));
    }
    
    final dailyAverage = weekLogs.isNotEmpty ? weeklyTotal / 7 : 0.0;
    
    final Map<String, double> weeklyMap = {};
    for (final log in monthLogs) {
      final logDate = DateTime.parse(log.date);
      final weekNumber = ((logDate.day - 1) ~/ 7) + 1;
      final weekLabel = 'Week $weekNumber';
      weeklyMap[weekLabel] = (weeklyMap[weekLabel] ?? 0) + log.carbonEmission;
    }
    
    final monthlyEmissions = weeklyMap.entries.map((e) => WeeklyEmission(week: e.key, emission: e.value)).toList();
    
    return AnalyticsModel(
      dailyEmissions: dailyEmissions,
      weeklyTotal: weeklyTotal,
      monthlyTotal: monthlyTotal,
      yearlyTotal: yearlyTotal,
      monthlyEmissions: monthlyEmissions,
      emissionsByAppliance: emissionsByAppliance,
      topAppliances: emissionsByAppliance.take(5).toList(),
      highestEmissionAppliance: highestEmissionAppliance,
      todayEmission: todayEmission,
      dailyAverage: dailyAverage,
      totalCarbonEmissions: yearlyTotal,
    );
  }

  Future<List<EcoTipModel>> getEcoTips({int limit = 5}) async {
    if (useMockData) {
      printDebug('Using mock data for getEcoTips');
      return _getMockEcoTips(limit);
    }
    try {
      printDebug('Fetching eco tips from $baseUrl/analytics/tips/list?limit=$limit');
      final response = await _client.get(
        Uri.parse('$baseUrl/analytics/tips/list?limit=$limit'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      printDebug('Eco tips response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        printDebug('${data.length} eco tips received');
        return data.map((e) => EcoTipModel.fromJson(e)).toList();
      } else {
        printDebug('Eco tips error - ${response.statusCode}');
        throw Exception('Failed to load eco tips: ${response.statusCode}');
      }
    } catch (e) {
      printDebug('Eco tips exception - $e');
      rethrow;
    }
  }

  List<EcoTipModel> _getMockEcoTips(int limit) {
    final allTips = [
      EcoTipModel(id: 1, title: 'Switch to LED', description: 'Replace incandescent bulbs with LED lights to save up to 75% energy.', category: 'Lighting'),
      EcoTipModel(id: 2, title: 'Optimal Temperature', description: 'Set AC to 24°C for optimal energy efficiency.', category: 'Cooling'),
      EcoTipModel(id: 3, title: 'Unplug Idle Devices', description: 'Unplug chargers and devices when not in use to eliminate phantom energy consumption.', category: 'General'),
      EcoTipModel(id: 4, title: 'Use Natural Light', description: 'Maximize natural daylight to reduce artificial lighting needs.', category: 'Lighting'),
      EcoTipModel(id: 5, title: 'Energy Star Appliances', description: 'Choose Energy Star certified appliances for 10-50% less energy consumption.', category: 'General'),
      EcoTipModel(id: 6, title: 'Regular Maintenance', description: 'Clean AC filters monthly for better efficiency and lower emissions.', category: 'Cooling'),
      EcoTipModel(id: 7, title: 'Power Strip Strategy', description: 'Use power strips to easily switch off multiple devices at once.', category: 'General'),
      EcoTipModel(id: 8, title: 'Efficient Cooking', description: 'Use lids while cooking to reduce energy usage by up to 30%.', category: 'Kitchen'),
    ];
    return allTips.take(limit).toList();
  }

  Future<double> calculateCarbonFootprint({
    required double electricity,
    required double transport,
    double diet = 0.0,
  }) async {
    if (useMockData) {
      return (electricity * 0.5) + (transport * 0.2) + (diet * 0.3);
    }
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/calculate'),
        headers: await _getHeaders(),
        body: json.encode({
          'electricity': electricity,
          'transport': transport,
          'diet': diet,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['carbon_footprint'] as double;
      } else {
        throw Exception('Failed to calculate carbon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to calculate carbon: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/user/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Invalid email or password'};
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/user/register'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        return {'success': false, 'message': 'Email already registered'};
      } else {
        return {'success': false, 'message': 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
