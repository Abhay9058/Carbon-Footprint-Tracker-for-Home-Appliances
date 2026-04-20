import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/carbon_calculator.dart';
import '../models/usage_log_model.dart';
import '../models/appliance_model.dart';

class ActivityCard extends StatelessWidget {
  final UsageLogModel log;
  final ApplianceModel? appliance;

  const ActivityCard({
    super.key,
    required this.log,
    this.appliance,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
          ),
          color: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    appliance != null
                        ? ApplianceUtils.getApplianceIcon(appliance!.applianceType)
                        : Icons.electrical_services,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appliance?.name ?? 'Unknown Appliance',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${log.hours} hours • ${DateFormatter.formatDateForDisplay(log.date)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    CarbonCalculator.formatEmission(log.carbonEmission),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
