import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _errorMessage;
  bool _darkMode = false;
  bool _ecoTipsNotifications = true;
  bool _onboardingComplete = false;
  bool _isLoggedIn = false;

  AuthProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorMessage => _errorMessage;
  bool get darkMode => _darkMode;
  bool get ecoTipsNotifications => _ecoTipsNotifications;
  bool get onboardingComplete => _onboardingComplete;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    notifyListeners();
  }

  void setOnboardingComplete(bool value) {
    _onboardingComplete = value;
    notifyListeners();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.getUser(AppConstants.defaultUserId);
      _darkMode = _user?.darkMode ?? false;
      _ecoTipsNotifications = _user?.ecoTipsNotifications ?? true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response['success'] == true) {
        _user = UserModel(
          id: response['user_id'] ?? 1,
          username: response['user']?['username'] ?? 'User',
          email: response['user']?['email'] ?? email,
          role: response['user']?['role'] ?? 'user',
          memberSince: response['user']?['member_since'] ?? DateTime.now().toIso8601String().split('T')[0],
          totalCarbonEmissions: (response['user']?['total_carbon_emissions'] ?? 0).toDouble(),
          darkMode: response['user']?['dark_mode'] ?? false,
          ecoTipsNotifications: response['user']?['eco_tips_notifications'] ?? true,
        );
        _isLoggedIn = true;
        _isLoading = false;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setInt('user_id', _user!.id);
        await prefs.setString('user_email', _user!.email ?? email);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(name, email, password);
      
      if (response['success'] == true) {
        _user = UserModel(
          id: response['user_id'] ?? 1,
          username: response['user']?['username'] ?? name,
          email: response['user']?['email'] ?? email,
          role: response['user']?['role'] ?? 'user',
          memberSince: response['user']?['member_since'] ?? DateTime.now().toIso8601String().split('T')[0],
          totalCarbonEmissions: (response['user']?['total_carbon_emissions'] ?? 0).toDouble(),
          darkMode: response['user']?['dark_mode'] ?? false,
          ecoTipsNotifications: response['user']?['eco_tips_notifications'] ?? true,
        );
        _isLoggedIn = true;
        _isLoading = false;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setInt('user_id', _user!.id);
        await prefs.setString('user_email', _user!.email ?? email);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _user = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_id');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userId = prefs.getInt('user_id');

    if (isLoggedIn && userId != null) {
      _isLoggedIn = true;
      await loadUser();
    }
    notifyListeners();
  }

  Future<void> updateUsername(String username) async {
    try {
      _user = await _apiService.updateUser(
        AppConstants.defaultUserId,
        {'username': username},
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    notifyListeners();

    try {
      _user = await _apiService.updateUser(
        AppConstants.defaultUserId,
        {'dark_mode': _darkMode},
      );
    } catch (e) {
      _darkMode = !_darkMode;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleEcoTipsNotifications() async {
    _ecoTipsNotifications = !_ecoTipsNotifications;
    notifyListeners();

    try {
      _user = await _apiService.updateUser(
        AppConstants.defaultUserId,
        {'eco_tips_notifications': _ecoTipsNotifications},
      );
    } catch (e) {
      _ecoTipsNotifications = !_ecoTipsNotifications;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _errorMessage = null;
    notifyListeners();
  }
}
