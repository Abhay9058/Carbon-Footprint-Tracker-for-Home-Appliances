import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/carbon_calculator.dart';
import '../../core/utils/animations.dart';
import '../../providers/app_data_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/eco_tip_card.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/charts.dart';
import '../../models/appliance_model.dart';
import '../../models/usage_log_model.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToAddAppliance;
  final Function(int) onNavigateToLogUsage;

  const DashboardScreen({
    super.key,
    required this.onNavigateToAddAppliance,
    required this.onNavigateToLogUsage,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppDataProvider>().loadInitialData();
            },
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransitionX(
                    child: const Icon(
                      Icons.eco,
                      size: 80,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: AppColors.primaryGreen),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            color: AppColors.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 100),
                    child: _buildStatCards(provider),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 200),
                    child: _buildWeeklyChart(provider),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 300),
                    child: _buildPieChart(provider),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 400),
                    child: _buildHighestEmissionAppliance(provider),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 500),
                    child: _buildEcoTips(provider),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 600),
                    child: _buildRecentActivity(provider),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 700),
                    child: _buildActionButtons(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(AppDataProvider provider) {
    final analytics = provider.analytics;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carbon Footprint Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        Text(
          'Daily Emissions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 350;
            if (isNarrow) {
              return Column(
                children: [
                  StatCard(
                    title: "Today's Emission",
                    value: CarbonCalculator.formatEmissionKg(
                      analytics?.todayEmission ?? 0,
                    ),
                    icon: Icons.today,
                    iconColor: AppColors.lightGreen,
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Daily Average',
                    value: CarbonCalculator.formatEmissionKg(
                      analytics?.dailyAverage ?? 0,
                    ),
                    icon: Icons.trending_up,
                    iconColor: AppColors.tealAccent,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: "Today's Emission",
                    value: CarbonCalculator.formatEmissionKg(
                      analytics?.todayEmission ?? 0,
                    ),
                    icon: Icons.today,
                    iconColor: AppColors.lightGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Daily Average',
                    value: CarbonCalculator.formatEmissionKg(
                      analytics?.dailyAverage ?? 0,
                    ),
                    icon: Icons.trending_up,
                    iconColor: AppColors.tealAccent,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        
        Text(
          'Cumulative Emissions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 350;
            if (isNarrow) {
              return Column(
                children: [
                  StatCard(
                    title: 'Weekly Total',
                    value: CarbonCalculator.formatEmissionKg(
                      analytics?.weeklyTotal ?? 0,
                    ),
                    icon: Icons.calendar_view_week,
                    iconColor: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Monthly Total',
                    value: CarbonCalculator.formatEmissionKg(
                      analytics?.monthlyTotal ?? 0,
                    ),
                    icon: Icons.calendar_month,
                    iconColor: AppColors.ecoGreen,
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Yearly Total',
                    value: CarbonCalculator.formatEmissionKg(
                      analytics?.yearlyTotal ?? 0,
                    ),
                    icon: Icons.calendar_today,
                    iconColor: AppColors.darkGreen,
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Appliances',
                    value: '${provider.appliances.length}',
                    icon: Icons.devices,
                    iconColor: AppColors.primaryGreen,
                  ),
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Weekly Total',
                        value: CarbonCalculator.formatEmissionKg(
                          analytics?.weeklyTotal ?? 0,
                        ),
                        icon: Icons.calendar_view_week,
                        iconColor: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        title: 'Monthly Total',
                        value: CarbonCalculator.formatEmissionKg(
                          analytics?.monthlyTotal ?? 0,
                        ),
                        icon: Icons.calendar_month,
                        iconColor: AppColors.ecoGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Yearly Total',
                        value: CarbonCalculator.formatEmissionKg(
                          analytics?.yearlyTotal ?? 0,
                        ),
                        icon: Icons.calendar_today,
                        iconColor: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        title: 'Appliances',
                        value: '${provider.appliances.length}',
                        icon: Icons.devices,
                        iconColor: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(AppDataProvider provider) {
    final dailyEmissions = provider.analytics?.dailyEmissions ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Emission Trend',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your daily carbon footprint',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryGreen),
                      const SizedBox(width: 4),
                      const Text(
                        '7 Days',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      'kg CO₂',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final chartHeight = constraints.maxWidth > 300 ? 160.0 : 140.0;
                      return SizedBox(
                        height: chartHeight,
                        child: dailyEmissions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.show_chart, size: 40, color: AppColors.grey.withValues(alpha: 0.5)),
                                    const SizedBox(height: 8),
                                    Text('No emission data yet', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                                  ],
                                ),
                              )
                            : EmissionLineChart(data: dailyEmissions),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(AppDataProvider provider) {
    final emissionsByAppliance = provider.analytics?.emissionsByAppliance ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appliance-Wise Emissions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Distribution by device',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxWidth > 300 ? 160.0 : 140.0;
                return SizedBox(
                  height: chartHeight,
                  child: emissionsByAppliance.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pie_chart, size: 40, color: AppColors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 8),
                              Text('No appliance data yet', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                        )
                      : EmissionPieChart(data: emissionsByAppliance),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighestEmissionAppliance(AppDataProvider provider) {
    final highest = provider.analytics?.highestEmissionAppliance;
    
    if (highest == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      color: AppColors.errorRed.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    color: AppColors.errorRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Highest Emission Appliance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.errorRed,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 300;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highest.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${highest.type} • Qty: ${highest.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          CarbonCalculator.formatEmissionKg(highest.emission),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            highest.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${highest.type} • Qty: ${highest.quantity}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        CarbonCalculator.formatEmissionKg(highest.emission),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Consider reducing usage or upgrading to energy-efficient model',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoTips(AppDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Eco Friendly Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => _showAllEcoTips(context, provider),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...provider.ecoTips.take(3).map((tip) => EcoTipCard(tip: tip)),
      ],
    );
  }

  Widget _buildRecentActivity(AppDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (provider.recentActivity.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: AppColors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...provider.recentActivity.take(5).map((log) {
            final appliance = provider.getApplianceById(log.applianceId);
            return ActivityCard(log: log, appliance: appliance);
          }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onNavigateToAddAppliance,
                icon: const Icon(Icons.add),
                label: const Text('Add Appliance'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showLogUsageDialog(),
                icon: const Icon(Icons.add_chart),
                label: const Text('Log Usage'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/achievements');
            },
            icon: const Icon(Icons.emoji_events),
            label: const Text('View Achievements'),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.softGreen,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogUsageDialog() {
    final provider = context.read<AppDataProvider>();
    if (provider.appliances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add an appliance first'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    ApplianceModel? selectedAppliance;
    final hoursController = TextEditingController();
    String selectedDate = DateFormatter.getTodayString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.glassWhite,
          title: const Text('Log Usage', style: TextStyle(color: AppColors.primaryGreen)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ApplianceModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Appliance',
                  ),
                  dropdownColor: AppColors.white,
                  items: provider.appliances.map((app) {
                    return DropdownMenuItem(
                      value: app,
                      child: Text('${app.name} (x${app.quantity})', style: const TextStyle(color: AppColors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAppliance = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Hours Used',
                    suffixText: 'hours',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date', style: TextStyle(color: AppColors.black)),
                  subtitle: Text(DateFormatter.formatDate(selectedDate), style: const TextStyle(color: AppColors.black)),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.black),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date.toIso8601String().split('T')[0];
                      });
                    }
                  },
                ),
                if (selectedAppliance != null && hoursController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Emission:', style: TextStyle(color: AppColors.black)),
                          Text(
                            CarbonCalculator.formatEmissionKg(
                              CarbonCalculator.calculateEmission(
                                wattage: selectedAppliance!.wattage,
                                hours: double.tryParse(hoursController.text) ?? 0,
                                quantity: selectedAppliance!.quantity,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAppliance == null || hoursController.text.isEmpty) {
                  return;
                }

                final log = UsageLogCreate(
                  applianceId: selectedAppliance!.id,
                  hours: double.tryParse(hoursController.text) ?? 0,
                  date: selectedDate,
                );

                final success = await provider.logUsage(log);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Usage logged successfully!'
                            : 'Failed to log usage',
                      ),
                      backgroundColor: success
                          ? AppColors.primaryGreen
                          : AppColors.errorRed,
                    ),
                  );
                }
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllEcoTips(BuildContext context, AppDataProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      'All Eco Tips',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.ecoTips.length,
                  itemBuilder: (context, index) {
                    final tip = provider.ecoTips[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tip.category,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tip.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
