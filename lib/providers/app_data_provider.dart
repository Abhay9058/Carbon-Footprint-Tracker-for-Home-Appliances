import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/appliance_model.dart';
import '../models/usage_log_model.dart';
import '../models/analytics_model.dart';
import '../models/eco_tip_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../screens/gamification/achievements_screen.dart';

class AppDataProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  UserModel? _user;
  List<ApplianceModel> _appliances = [];
  List<UsageLogModel> _usageLogs = [];
  List<UsageLogModel> _recentActivity = [];
  AnalyticsModel? _analytics;
  List<EcoTipModel> _ecoTips = [];
  
  bool _isLoading = false;
  bool _isAddingAppliance = false;
  bool _isRefreshing = false;
  String? _error;

  AppDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  bool get isUsingMockData => _apiService.useMockData;
  
  Future<void> setMockDataMode(bool useMock) async {
    _apiService.useMockData = useMock;
    await loadInitialData();
    notifyListeners();
  }

  Future<void> initializeAndCheckConnection() async {
    await _apiService.checkAndUseOfflineMode();
    notifyListeners();
  }

  UserModel? get user => _user;
  List<ApplianceModel> get appliances => _appliances;
  List<UsageLogModel> get usageLogs => _usageLogs;
  List<UsageLogModel> get recentActivity => _recentActivity;
  AnalyticsModel? get analytics => _analytics;
  List<EcoTipModel> get ecoTips => _ecoTips;
  bool get isLoading => _isLoading;
  bool get isAddingAppliance => _isAddingAppliance;
  bool get isRefreshing => _isRefreshing;
  bool get hasData => _analytics != null && _appliances.isNotEmpty;
  String? get error => _error;

  Future<int> get userId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? AppConstants.defaultUserId;
  }

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? AppConstants.defaultUserId;
  }

  Future<void> loadInitialData() async {
    debugPrint('AppDataProvider: Starting loadInitialData');
    _isLoading = true;
    _isRefreshing = false;
    _error = null;
    
    await _apiService.checkAndUseOfflineMode();
    
    notifyListeners();

    try {
      final currentUserId = await _getUserId();
      
      final futures = await Future.wait([
        _apiService.getUser(currentUserId).then((v) => <dynamic>[v, 'user']),
        _apiService.getAppliances(currentUserId).then((v) => <dynamic>[v, 'appliances']),
        _apiService.getAnalytics(currentUserId).then((v) => <dynamic>[v, 'analytics']),
        _apiService.getUsageLogs(currentUserId, limit: 10).then((v) => <dynamic>[v, 'logs']),
        _apiService.getEcoTips(limit: 5).then((v) => <dynamic>[v, 'tips']),
      ].map((f) => f.catchError((e) {
        debugPrint('loadInitialData error: $e');
        return <dynamic>[null, 'error'];
      })));

      for (final result in futures) {
        final type = result[1] as String;
        final value = result[0];
        switch (type) {
          case 'user':
            _user = value as UserModel?;
            break;
          case 'appliances':
            _appliances = (value as List<ApplianceModel>?) ?? [];
            break;
          case 'analytics':
            _analytics = value as AnalyticsModel?;
            break;
          case 'logs':
            _recentActivity = (value as List<UsageLogModel>?) ?? [];
            break;
          case 'tips':
            _ecoTips = (value as List<EcoTipModel>?) ?? [];
            break;
        }
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
      debugPrint('AppDataProvider: All data loaded successfully');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('AppDataProvider: ERROR - $e');
      notifyListeners();
    }
  }

  Future<void> refreshAnalytics() async {
    _isRefreshing = true;
    notifyListeners();
    
    try {
      await loadAnalytics();
      await loadRecentActivity();
    } catch (e) {
      debugPrint('refreshAnalytics error: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    try {
      final currentUserId = await _getUserId();
      _user = await _apiService.getUser(currentUserId);
      debugPrint('AppDataProvider: User data: $_user');
      notifyListeners();
    } catch (e) {
      debugPrint('AppDataProvider: loadUser error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAppliances() async {
    try {
      final currentUserId = await _getUserId();
      _appliances = await _apiService.getAppliances(currentUserId);
      debugPrint('AppDataProvider: Appliances: ${_appliances.length} items');
      notifyListeners();
    } catch (e) {
      debugPrint('AppDataProvider: loadAppliances error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUsageLogs() async {
    try {
      final currentUserId = await _getUserId();
      _usageLogs = await _apiService.getUsageLogs(currentUserId);
      debugPrint('AppDataProvider: Usage logs: ${_usageLogs.length} items');
      notifyListeners();
    } catch (e) {
      debugPrint('AppDataProvider: loadUsageLogs error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadRecentActivity() async {
    try {
      final currentUserId = await _getUserId();
      _recentActivity = await _apiService.getUsageLogs(currentUserId, limit: 10);
      debugPrint('AppDataProvider: Recent activity: ${_recentActivity.length} items');
      notifyListeners();
    } catch (e) {
      debugPrint('AppDataProvider: loadRecentActivity error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAnalytics() async {
    try {
      final currentUserId = await _getUserId();
      _analytics = await _apiService.getAnalytics(currentUserId);
      debugPrint('AppDataProvider: Analytics loaded: today=${_analytics?.todayEmission}');
      notifyListeners();
    } catch (e) {
      debugPrint('AppDataProvider: loadAnalytics error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadEcoTips() async {
    try {
      _ecoTips = await _apiService.getEcoTips(limit: 5);
      debugPrint('AppDataProvider: Eco tips: ${_ecoTips.length} items');
      notifyListeners();
    } catch (e) {
      debugPrint('AppDataProvider: loadEcoTips error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addAppliance(ApplianceCreate appliance) async {
    _isAddingAppliance = true;
    _error = null;
    notifyListeners();
    
    try {
      final currentUserId = await _getUserId();
      final newAppliance = await _apiService.createAppliance(currentUserId, appliance);
      _appliances = [..._appliances, newAppliance];
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      _analytics = null;
      notifyListeners();
      
      await loadAnalytics();
      await loadRecentActivity();
      
      _updateAchievements();
      
      _isAddingAppliance = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Add appliance error: $e');
      _error = e.toString();
      _isAddingAppliance = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAppliance(int applianceId) async {
    try {
      await _apiService.deleteAppliance(applianceId);
      _appliances.removeWhere((a) => a.id == applianceId);
      notifyListeners();
      await loadAnalytics();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> logUsage(UsageLogCreate log) async {
    try {
      final currentUserId = await _getUserId();
      final newLog = await _apiService.createUsageLog(currentUserId, log);
      _usageLogs.insert(0, newLog);
      _recentActivity.insert(0, newLog);
      if (_recentActivity.length > 10) {
        _recentActivity.removeLast();
      }
      notifyListeners();
      
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await loadAnalytics();
        await loadUser();
        _updateAchievements();
      });
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  ApplianceModel? getApplianceById(int id) {
    try {
      return _appliances.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<double> calculateCarbonFootprint({
    required double electricity,
    required double transport,
    double diet = 0.0,
  }) async {
    try {
      return await _apiService.calculateCarbonFootprint(
        electricity: electricity,
        transport: transport,
        diet: diet,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await loadInitialData();
  }

  void _updateAchievements() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = AppConstants.appNavigatorKey.currentContext;
        if (context != null) {
          try {
            final achievementsProvider = Provider.of<AchievementsProvider>(
              context,
              listen: false,
            );
            achievementsProvider.checkAndUnlockAchievements(
              applianceCount: _appliances.length,
              logCount: _usageLogs.length,
              totalEmissionsSaved: _analytics?.totalCarbonEmissions ?? 0,
              currentStreak: _calculateStreak(),
            );
          } catch (e) {
            debugPrint('Error updating achievements: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Error updating achievements: $e');
    }
  }

  int _calculateStreak() {
    if (_recentActivity.isEmpty) return 0;
    
    final dates = _recentActivity.map((l) => l.date).toSet().toList()..sort();
    if (dates.isEmpty) return 0;
    
    int streak = 1;
    for (int i = dates.length - 1; i > 0; i--) {
      final current = DateTime.parse(dates[i]);
      final previous = DateTime.parse(dates[i - 1]);
      final difference = current.difference(previous).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
