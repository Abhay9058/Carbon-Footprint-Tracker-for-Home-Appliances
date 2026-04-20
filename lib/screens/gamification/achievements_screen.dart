import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/eco_background.dart';
import '../../core/utils/animations.dart';
import '../../providers/auth_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final BadgeTier tier;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
  });

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      tier: tier,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target,
    );
  }
}

enum BadgeTier { bronze, silver, gold, platinum }

class AchievementService {
  static List<Achievement> getAllAchievements() {
    return [
      Achievement(
        id: 'first_appliance',
        title: 'First Step',
        description: 'Add your first appliance',
        icon: Icons.power,
        color: const Color(0xFFCD7F32),
        tier: BadgeTier.bronze,
        target: 1,
      ),
      Achievement(
        id: 'appliance_master',
        title: 'Appliance Master',
        description: 'Add 10 appliances',
        icon: Icons.devices,
        color: const Color(0xFFCD7F32),
        tier: BadgeTier.bronze,
        target: 10,
      ),
      Achievement(
        id: 'first_log',
        title: 'Getting Started',
        description: 'Log your first usage',
        icon: Icons.add_chart,
        color: const Color(0xFFC0C0C0),
        tier: BadgeTier.bronze,
        target: 1,
      ),
      Achievement(
        id: 'logging_pro',
        title: 'Logging Pro',
        description: 'Log usage 50 times',
        icon: Icons.trending_up,
        color: const Color(0xFFC0C0C0),
        tier: BadgeTier.silver,
        target: 50,
      ),
      Achievement(
        id: 'carbon_saver',
        title: 'Carbon Saver',
        description: 'Save 10kg CO₂ compared to average',
        icon: Icons.eco,
        color: const Color(0xFFC0C0C0),
        tier: BadgeTier.silver,
        target: 10,
      ),
      Achievement(
        id: 'week_streak',
        title: 'Week Warrior',
        description: 'Log usage for 7 consecutive days',
        icon: Icons.local_fire_department,
        color: const Color(0xFFFFD700),
        tier: BadgeTier.gold,
        target: 7,
      ),
      Achievement(
        id: 'month_streak',
        title: 'Consistency King',
        description: 'Log usage for 30 consecutive days',
        icon: Icons.emoji_events,
        color: const Color(0xFFFFD700),
        tier: BadgeTier.gold,
        target: 30,
      ),
      Achievement(
        id: 'eco_champion',
        title: 'Eco Champion',
        description: 'Reduce emissions by 50%',
        icon: Icons.star,
        color: const Color(0xFFE5E4E2),
        tier: BadgeTier.platinum,
        target: 50,
      ),
      Achievement(
        id: 'green_influencer',
        title: 'Green Influencer',
        description: 'Share your achievements 10 times',
        icon: Icons.share,
        color: const Color(0xFFE5E4E2),
        tier: BadgeTier.platinum,
        target: 10,
      ),
    ];
  }

  static Widget getTierIcon(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze:
        return const Icon(Icons.circle, color: Color(0xFFCD7F32), size: 16);
      case BadgeTier.silver:
        return const Icon(Icons.circle, color: Color(0xFFC0C0C0), size: 16);
      case BadgeTier.gold:
        return const Icon(Icons.circle, color: Color(0xFFFFD700), size: 16);
      case BadgeTier.platinum:
        return const Icon(Icons.circle, color: Color(0xFFE5E4E2), size: 16);
    }
  }
}

class AchievementsProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  int _totalPoints = 0;

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  int get totalPoints => _totalPoints;
  int get unlockedCount => unlockedAchievements.length;
  int get totalCount => _achievements.length;

  AchievementsProvider() {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    _achievements = AchievementService.getAllAchievements();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('achievements_progress');
      if (savedData != null) {
        final Map<String, dynamic> data = json.decode(savedData);
        for (int i = 0; i < _achievements.length; i++) {
          if (data.containsKey(_achievements[i].id)) {
            final saved = data[_achievements[i].id];
            _achievements[i] = _achievements[i].copyWith(
              isUnlocked: saved['isUnlocked'] ?? false,
              progress: saved['progress'] ?? 0,
              unlockedAt: saved['unlockedAt'] != null 
                  ? DateTime.parse(saved['unlockedAt']) 
                  : null,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
    
    _calculatePoints();
    notifyListeners();
  }

  Future<void> _saveAchievements() async {
    try {
      final Map<String, dynamic> data = {};
      for (final achievement in _achievements) {
        data[achievement.id] = {
          'isUnlocked': achievement.isUnlocked,
          'progress': achievement.progress,
          'unlockedAt': achievement.unlockedAt?.toIso8601String(),
        };
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('achievements_progress', json.encode(data));
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  void _calculatePoints() {
    _totalPoints = 0;
    for (final achievement in _achievements) {
      if (achievement.isUnlocked) {
        switch (achievement.tier) {
          case BadgeTier.bronze:
            _totalPoints += 10;
          case BadgeTier.silver:
            _totalPoints += 25;
          case BadgeTier.gold:
            _totalPoints += 50;
          case BadgeTier.platinum:
            _totalPoints += 100;
        }
      }
    }
    _saveAchievements();
  }

  void updateProgress(String achievementId, int progress) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      final achievement = _achievements[index];
      if (!achievement.isUnlocked && progress >= achievement.target) {
        _achievements[index] = achievement.copyWith(
          progress: progress,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      } else if (!achievement.isUnlocked) {
        _achievements[index] = achievement.copyWith(progress: progress);
      }
      _calculatePoints();
      notifyListeners();
    }
  }

  void unlockAchievement(String achievementId) {
    updateProgress(achievementId, 999);
  }

  void checkAndUnlockAchievements({
    required int applianceCount,
    required int logCount,
    required double totalEmissionsSaved,
    required int currentStreak,
  }) {
    updateProgress('first_appliance', applianceCount > 0 ? 1 : 0);
    updateProgress('appliance_master', applianceCount);
    updateProgress('first_log', logCount > 0 ? 1 : 0);
    updateProgress('logging_pro', logCount);
    updateProgress('carbon_saver', totalEmissionsSaved.toInt());
    updateProgress('week_streak', currentStreak);
    updateProgress('month_streak', currentStreak);
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AchievementsBackground(
      enableMotion: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Achievements'),
        ),
        body: Consumer<AchievementsProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 500),
                    child: _buildStatsCard(context, provider),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: _buildAchievementsList(context, provider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AchievementsProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.unlockedCount}/${provider.totalCount} Unlocked',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.totalPoints} Points',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context, AchievementsProvider provider) {
    final sortedAchievements = List<Achievement>.from(provider.achievements)
      ..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return b.tier.index.compareTo(a.tier.index);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Achievements',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...sortedAchievements.asMap().entries.map((entry) {
          final index = entry.key;
          final achievement = entry.value;
          return FadeSlideTransition(
            duration: const Duration(milliseconds: 500),
            delay: Duration(milliseconds: 300 + (index * 50)),
            child: _buildAchievementCard(context, achievement),
          );
        }),
      ],
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color.withValues(alpha: 0.2)
                      : AppColors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked ? achievement.color : AppColors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                          ),
                        ),
                        AchievementService.getTierIcon(achievement.tier),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (!achievement.isUnlocked) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: achievement.progressPercentage,
                          backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.progress}/${achievement.target}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (achievement.isUnlocked)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
