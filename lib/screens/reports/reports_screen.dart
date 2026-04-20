import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/carbon_calculator.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/charts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Reports & Analytics', style: TextStyle(color: AppColors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: AppColors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.grey,
          tabs: const [
            Tab(text: 'Charts', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Usage Logs', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (provider.error != null && !provider.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadInitialData(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildChartsTab(provider),
              _buildLogsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartsTab(AppDataProvider provider) {
    final analytics = provider.analytics;

    return RefreshIndicator(
      onRefresh: () => provider.loadAnalytics(),
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(analytics),
            const SizedBox(height: 24),
            _buildLineChart(provider),
            const SizedBox(height: 24),
            _buildBarChart(provider),
            const SizedBox(height: 24),
            _buildPieChart(provider),
            const SizedBox(height: 24),
            _buildTopAppliances(provider),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryGreen),
                ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Weekly Total',
                CarbonCalculator.formatEmissionKg(analytics?.weeklyTotal ?? 0),
                Icons.calendar_view_week,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Daily Average',
                CarbonCalculator.formatEmissionKg(analytics?.dailyAverage ?? 0),
                Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Emissions',
                CarbonCalculator.formatEmissionKg(
                  context.read<AppDataProvider>().user?.totalCarbonEmissions ?? 0,
                ),
                Icons.eco,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Appliances',
                '${analytics?.emissionsByAppliance.length ?? 0}',
                Icons.devices,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(AppDataProvider provider) {
    final dailyEmissions = provider.analytics?.dailyEmissions ?? [];

    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Emissions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Last 7 Days',
                    style: TextStyle(fontSize: 11, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: dailyEmissions.isEmpty
                  ? _buildEmptyChart('No data available')
                  : EmissionLineChart(data: dailyEmissions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(AppDataProvider provider) {
    final monthlyEmissions = provider.analytics?.monthlyEmissions ?? [];

    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Emissions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Last 4 Weeks',
                    style: TextStyle(fontSize: 11, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: monthlyEmissions.isEmpty
                  ? _buildEmptyChart('No data available')
                  : EmissionBarChart(data: monthlyEmissions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(AppDataProvider provider) {
    final emissionsByAppliance = provider.analytics?.emissionsByAppliance ?? [];

    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emissions by Appliance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: emissionsByAppliance.isEmpty
                  ? _buildEmptyChart('No data available')
                  : EmissionPieChart(data: emissionsByAppliance),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderChart(String chartType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(chartType, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 48, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildTopAppliances(AppDataProvider provider) {
    final topAppliances = provider.analytics?.topAppliances ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Contributing Appliances',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 12),
        if (topAppliances.isEmpty)
          Card(
            color: const Color(0xFF1E1E1E),
            child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No data available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
          )
        else
          ...topAppliances.asMap().entries.map((entry) {
            final index = entry.key;
            final appliance = entry.value;
            final maxEmission = topAppliances.first.emission;
            final percentage = maxEmission > 0 ? appliance.emission / maxEmission : 0.0;

            return Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              appliance.name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CarbonCalculator.formatEmissionKg(appliance.emission),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.grey.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildLogsTab(AppDataProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadUsageLogs(),
      color: AppColors.primaryGreen,
      child: provider.usageLogs.isEmpty
          ? _buildEmptyLogs()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.usageLogs.length,
              itemBuilder: (context, index) {
                final log = provider.usageLogs[index];
                final appliance = provider.getApplianceById(log.applianceId);
                return _buildLogItem(log, appliance);
              },
            ),
    );
  }

  Widget _buildEmptyLogs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 48,
              color: AppColors.primaryGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No usage logs yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your appliance usage',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddAppliance(),
            icon: const Icon(Icons.add),
            label: const Text('Log Usage'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(dynamic log, dynamic appliance) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final date = DateTime.tryParse(log.date ?? '') ?? DateTime.now();

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.softGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.electrical_services,
            color: AppColors.primaryGreen,
          ),
        ),
        title: Text(
          appliance?.name ?? 'Unknown Appliance',
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
        ),
        subtitle: Text(
          '${log.hours} hours • ${dateFormat.format(date)}',
          style: TextStyle(color: AppColors.white.withValues(alpha: 0.7)),
        ),
        trailing: Text(
          CarbonCalculator.formatEmissionKg(log.carbonEmission ?? 0),
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _exportToPdf() async {
    setState(() => _isExporting = true);

    try {
      final provider = context.read<AppDataProvider>();
      final authProvider = context.read<AuthProvider>();
      final analytics = provider.analytics;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Eco Warrior Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    DateFormat('MMM dd, yyyy').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'User: ${authProvider.user?.username ?? "N/A"}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Carbon Footprint Summary',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Value'],
              data: [
                ['Weekly Total', CarbonCalculator.formatEmissionKg(analytics?.weeklyTotal ?? 0)],
                ['Daily Average', CarbonCalculator.formatEmissionKg(analytics?.dailyAverage ?? 0)],
                ['Total Emissions', CarbonCalculator.formatEmissionKg(provider.user?.totalCarbonEmissions ?? 0)],
                ['Total Appliances', '${provider.appliances.length}'],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Appliances',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Name', 'Type', 'Wattage', 'Quantity'],
              data: provider.appliances
                  .map((a) => [a.name, a.applianceType, '${a.wattage}W', '${a.quantity}'])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Recent Usage Logs',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Appliance', 'Hours', 'Date', 'Emission'],
              data: provider.usageLogs.take(20).map((log) {
                final appliance = provider.getApplianceById(log.applianceId);
                return [
                  appliance?.name ?? 'Unknown',
                  '${log.hours}',
                  log.date ?? '',
                  CarbonCalculator.formatEmissionKg(log.carbonEmission ?? 0),
                ];
              }).toList(),
            ),
          ],
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/EcoWarrior_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Report saved to: ${file.path}'),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      } finally {
      setState(() => _isExporting = false);
    }
  }

  void _navigateToAddAppliance() {
    Navigator.of(context).pushNamed('/home');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Go to Add tab to log usage'),
        backgroundColor: AppColors.primaryGreen,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
