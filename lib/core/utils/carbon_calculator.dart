import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarbonCalculator {
  static const double emissionFactor = 0.82;

  static double calculateEmission({
    required double wattage,
    required double hours,
    required int quantity,
  }) {
    return (wattage * hours * quantity / 1000) * emissionFactor;
  }

  static String formatEmission(double emission) {
    if (emission < 1) {
      return '${(emission * 1000).toStringAsFixed(1)} g';
    }
    return '${emission.toStringAsFixed(2)} kg';
  }

  static String formatEmissionKg(double emission) {
    return '${emission.toStringAsFixed(3)} kg CO₂';
  }
}

class DateFormatter {
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final inputDate = DateTime(date.year, date.month, date.day);
      
      if (inputDate == today) {
        return 'Today';
      } else if (inputDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return DateFormat('EEEE, MMM dd').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  static String getTodayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}

class ApplianceUtils {
  static List<String> getApplianceTypes() {
    return [
      'Lighting',
      'Cooling',
      'Heating',
      'Entertainment',
      'Kitchen',
      'Laundry',
      'Computing',
      'Other',
    ];
  }

  static IconData getApplianceIcon(String type) {
    switch (type) {
      case 'Lighting':
        return Icons.lightbulb_outline;
      case 'Cooling':
        return Icons.ac_unit;
      case 'Heating':
        return Icons.whatshot_outlined;
      case 'Entertainment':
        return Icons.tv;
      case 'Kitchen':
        return Icons.kitchen;
      case 'Laundry':
        return Icons.local_laundry_service;
      case 'Computing':
        return Icons.computer;
      default:
        return Icons.devices_other;
    }
  }
}
