import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../models/analytics_model.dart';
import '../core/utils/carbon_calculator.dart';

class EmissionLineChart extends StatelessWidget {
  final List<DailyEmission> data;

  const EmissionLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxEmission = data.map((e) => e.emission).fold<double>(0.0, (a, b) => a > b ? a : b);
    // Handle empty data - show message only if all emissions are 0
    if (maxEmission == 0 && data.every((e) => e.emission == 0)) {
      return const Center(child: Text('No emissions recorded'));
    }

    final maxY = maxEmission > 0 ? maxEmission : 10.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.white,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].date;
                  final parts = date.split('-');
                  final day = parts.length >= 3 ? parts[2] : date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.white,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.emission);
            }).toList(),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppColors.lightGreen, AppColors.primaryGreen],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.primaryGreen,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withValues(alpha: 0.3),
                  AppColors.primaryGreen.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minY: 0,
      ),
    );
  }
}

class EmissionBarChart extends StatelessWidget {
  final List<WeeklyEmission> data;

  const EmissionBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxEmission = data.map((e) => e.emission).fold<double>(0.0, (a, b) => a > b ? a : b);
    // Handle empty data - show message only if all emissions are 0
    if (maxEmission == 0 && data.every((e) => e.emission == 0)) {
      return const Center(child: Text('No emissions recorded'));
    }

    final maxY = maxEmission > 0 ? maxEmission : 10.0;

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.white,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index].week,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.white,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.emission,
                gradient: const LinearGradient(
                  colors: [AppColors.lightGreen, AppColors.primaryGreen],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        maxY: maxY * 1.2,
      ),
    );
  }
}

class EmissionPieChart extends StatefulWidget {
  final List<ApplianceEmission> data;

  const EmissionPieChart({super.key, required this.data});

  @override
  State<EmissionPieChart> createState() => _EmissionPieChartState();
}

class _EmissionPieChartState extends State<EmissionPieChart> {
  int? _selectedIndex;

  static const List<Color> chartColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF8BC34A), // Light Green
    Color(0xFF3F51B5), // Indigo
    Color(0xFFFFC107), // Amber
    Color(0xFF009688), // Teal
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFCDDC39), // Lime
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF03A9F4), // Light Blue
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF7043), // Coral
    Color(0xFF26A69A), // Teal Dark
    Color(0xFFEC407A), // Pink Dark
  ];

  Color _getColor(int index) {
    return chartColors[index % chartColors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No appliance data'));
    }

    final total = widget.data.fold<double>(0, (sum, item) => sum + item.emission);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 350;
        
        return isWide
            ? _buildHorizontalLayout(total)
            : _buildVerticalLayout(total);
      },
    );
  }

  Widget _buildHorizontalLayout(double total) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildDonutChart(total),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildLegend(total),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(double total) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildDonutChart(total),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 50,
          child: _buildLegend(total, isScrollable: true),
        ),
      ],
    );
  }

  Widget _buildDonutChart(double total) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                if (event is FlTapUpEvent) {
                  final index = response?.touchedSection?.touchedSectionIndex ?? -1;
                  if (index >= 0 && index < widget.data.length) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                }
              },
            ),
            sectionsSpace: 2,
            centerSpaceRadius: 35,
            sections: widget.data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _selectedIndex == index;
              final percentage = (item.emission / total * 100);

              return PieChartSectionData(
                color: _getColor(index),
                value: item.emission,
                title: isSelected ? '${percentage.toStringAsFixed(1)}%' : '',
                radius: isSelected ? 55 : 45,
                titleStyle: TextStyle(
                  fontSize: isSelected ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                badgeWidget: isSelected
                    ? null
                    : percentage >= 10
                        ? Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                badgePositionPercentageOffset: 1.3,
              );
            }).toList(),
          ),
        ),
        _buildCenterContent(total),
      ],
    );
  }

  Widget _buildCenterContent(double total) {
    if (_selectedIndex != null && _selectedIndex! < widget.data.length) {
      final selectedItem = widget.data[_selectedIndex!];
      final percentage = (selectedItem.emission / total * 100);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getColor(_selectedIndex!).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getColor(_selectedIndex!),
                width: 2,
              ),
            ),
            child: Text(
              selectedItem.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getColor(_selectedIndex!),
            ),
          ),
          Text(
            '${selectedItem.emission.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        Text(
          '${total.toStringAsFixed(1)} kg',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(double total, {bool isScrollable = false}) {
    final legendItems = widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = _selectedIndex == index;
      final percentage = (item.emission / total * 100);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? _getColor(index).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: _getColor(index), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColor(index),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _getColor(index).withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? _getColor(index) : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}% • ${item.emission.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();

    if (isScrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: legendItems
              .map((widget) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget,
                  ))
              .toList(),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: legendItems,
    );
  }
}
