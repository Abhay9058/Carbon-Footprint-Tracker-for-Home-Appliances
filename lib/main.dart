import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/api_constants.dart';
import 'core/utils/eco_background.dart';
import 'providers/app_data_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/gamification/achievements_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/appliances/add_appliance_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

void main() {
  runApp(const EcoWarriorApp());
}

class EcoWarriorApp extends StatelessWidget {
  const EcoWarriorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: AppConstants.appNavigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: authProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/achievements': (context) => const AchievementsScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.checkOnboardingStatus();
    await authProvider.checkLoginStatus();

    if (!authProvider.onboardingComplete) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (!authProvider.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 70,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track Your Carbon Footprint',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Key _dashboardKey = UniqueKey();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _navigateToPage(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppDataProvider>().loadInitialData();
      });
    }
  }

  void _refreshDashboard() {
    setState(() {
      _dashboardKey = UniqueKey();
    });
    context.read<AppDataProvider>().loadInitialData();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBackgroundForPage(
      _currentIndex,
      Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(
              key: _dashboardKey,
              onNavigateToAddAppliance: () => _navigateToPage(1),
              onNavigateToLogUsage: (id) => _navigateToPage(1),
            ),
            AddApplianceScreen(
              onApplianceAdded: () {
                _navigateToPage(0);
              },
            ),
            const ReportsScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateToPage,
          backgroundColor: AppColors.white.withValues(alpha: 0.9),
          indicatorColor: AppColors.softGreen,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundForPage(int index, Widget child) {
    switch (index) {
      case 0:
        return EcoBackground(
          enableMotion: true,
          backgroundType: BackgroundType.dashboard,
          child: child,
        );
      case 1:
        return AppliancesBackground(
          enableMotion: true,
          child: child,
        );
      case 2:
        return ReportsBackground(
          enableMotion: true,
          child: child,
        );
      case 3:
        return EcoBackground(
          enableMotion: true,
          backgroundType: BackgroundType.dashboard,
          child: child,
        );
      default:
        return EcoBackground(
          enableMotion: true,
          backgroundType: BackgroundType.dashboard,
          child: child,
        );
    }
  }
}
