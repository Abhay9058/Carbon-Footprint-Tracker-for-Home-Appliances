import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/carbon_calculator.dart';
import '../models/appliance_model.dart';

class ApplianceCard extends StatelessWidget {
  final ApplianceModel appliance;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onLogUsage;

  const ApplianceCard({
    super.key,
    required this.appliance,
    this.onTap,
    this.onDelete,
    this.onLogUsage,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen.withValues(alpha: 0.4),
                                AppColors.lightGreen.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            ApplianceUtils.getApplianceIcon(appliance.applianceType),
                            color: AppColors.lightGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appliance.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appliance.applianceType,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.lightGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                onDelete?.call();
                              } else if (value == 'log') {
                                onLogUsage?.call();
                              }
                            },
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            color: const Color(0xFF1A1A1A),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'log',
                                child: Row(
                                  children: [
                                    Icon(Icons.add_chart, size: 20, color: AppColors.lightGreen),
                                    SizedBox(width: 8),
                                    Text('Log Usage', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          Icons.bolt,
                          '${appliance.wattage} W',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          Icons.tag,
                          'Qty: ${appliance.quantity}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.2),
            AppColors.primaryGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.lightGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
