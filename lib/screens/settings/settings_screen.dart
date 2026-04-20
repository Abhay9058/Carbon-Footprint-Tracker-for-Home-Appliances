import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/carbon_calculator.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_data_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: Consumer2<AuthProvider, AppDataProvider>(
        builder: (context, authProvider, appDataProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(context, authProvider),
                const SizedBox(height: 24),
                _buildCarbonStats(context, appDataProvider),
                const SizedBox(height: 24),
                _buildPreferencesSection(context, authProvider),
                const SizedBox(height: 24),
                _buildAccountSection(context),
                const SizedBox(height: 24),
                _buildAboutSection(context),
                const SizedBox(height: 24),
                _buildBackendStatusSection(context),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackendStatusSection(BuildContext context) {
    final appDataProvider = context.read<AppDataProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backend Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                appDataProvider.isUsingMockData ? Icons.cloud_off : Icons.cloud_done,
                color: appDataProvider.isUsingMockData ? AppColors.errorRed : AppColors.primaryGreen,
              ),
              title: Text(
                appDataProvider.isUsingMockData ? 'Offline Mode (Mock Data)' : 'Online Mode',
              ),
              subtitle: Text(
                appDataProvider.isUsingMockData
                    ? 'Using demo data - no backend required'
                    : 'Connected to server',
              ),
              trailing: Switch(
                value: !appDataProvider.isUsingMockData,
                onChanged: (value) {
                  appDataProvider.setMockDataMode(!value);
                },
                activeColor: AppColors.primaryGreen,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Backend URL'),
              subtitle: const Text('http://localhost:8001'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showBackendInfoDialog(context),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  void _showBackendInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.dns, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('Backend Configuration'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Backend URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('http://localhost:8001'),
              SizedBox(height: 16),
              Text(
                'To use with backend:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Start backend server on your PC'),
              Text('2. Find your PC\'s IP address'),
              Text('3. Update ApiConstants.baseUrl'),
              SizedBox(height: 16),
              Text(
                'For offline use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('The app works without backend using mock data. Toggle the switch above to switch between online/offline mode.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryGreen,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileRow(
              context,
              Icons.person,
              'Username',
              user?.username ?? 'Loading...',
              onTap: () => _showEditUsernameDialog(context, authProvider),
            ),
            const Divider(),
            _buildProfileRow(
              context,
              Icons.email,
              'Email',
              user?.email ?? 'Not set',
            ),
            const Divider(),
            _buildProfileRow(
              context,
              Icons.badge,
              'Role',
              user?.role ?? 'user',
            ),
            const Divider(),
            _buildProfileRow(
              context,
              Icons.calendar_today,
              'Member Since',
              user?.memberSince ?? 'Loading...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonStats(BuildContext context, AppDataProvider provider) {
    final totalEmissions = provider.user?.totalCarbonEmissions ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carbon Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco,
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
                          'Total Carbon Emissions',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CarbonCalculator.formatEmissionKg(totalEmissions),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Today',
                    CarbonCalculator.formatEmissionKg(
                      provider.analytics?.todayEmission ?? 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Weekly',
                    CarbonCalculator.formatEmissionKg(
                      provider.analytics?.weeklyTotal ?? 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Eco Tips Notifications'),
              subtitle: const Text('Receive eco-friendly tips and suggestions'),
              value: authProvider.ecoTipsNotifications,
              onChanged: (_) => authProvider.toggleEcoTipsNotifications(),
              activeColor: AppColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHelpSupportDialog(context),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPrivacyPolicyDialog(context),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.errorRed),
              title: const Text('Logout', style: TextStyle(color: AppColors.errorRed)),
              onTap: () => _showLogoutDialog(context),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Carbon Calculation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Track and reduce your carbon footprint by monitoring energy usage from household appliances.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Calculation Formula:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CO₂ (kg) = (Wattage × Hours × Quantity / 1000) × ${AppConstants.emissionFactor}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Where ${AppConstants.emissionFactor} is India\'s average emission factor per kWh (as per Central Electricity Authority).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUsernameDialog(BuildContext context, AuthProvider authProvider) {
    final controller = TextEditingController(text: authProvider.user?.username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter new username',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                authProvider.updateUsername(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username updated successfully!'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            const Text('Help & Support'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to Eco Warrior!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('How to use the app:'),
              SizedBox(height: 8),
              Text('1. Add your appliances in the Add tab'),
              Text('2. Log your daily usage'),
              Text('3. Track your carbon footprint'),
              Text('4. View reports and analytics'),
              SizedBox(height: 16),
              Text(
                'Need help? Contact us at:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text('Email: support@ecowarrior.app'),
              Text('Phone: +91 98765 43210'),
              SizedBox(height: 16),
              Text(
                'Office Hours:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text('Mon - Fri: 9:00 AM - 6:00 PM'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            const Text('Privacy Policy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last updated: January 2024',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              Text(
                'Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Eco Warrior collects only the data necessary to provide carbon footprint tracking services. This includes appliance information, usage logs, and usage patterns.',
              ),
              SizedBox(height: 16),
              Text(
                'Data Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your data is used solely for calculating carbon emissions and providing personalized eco-friendly tips. We do not sell or share your personal information.',
              ),
              SizedBox(height: 16),
              Text(
                'Data Storage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'All data is stored securely on our servers with industry-standard encryption. You can request deletion of your data at any time.',
              ),
              SizedBox(height: 16),
              Text(
                'Contact',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('For privacy concerns, contact:'),
              Text('privacy@ecowarrior.app'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
