import 'package:flutter/material.dart';
import '../widgets/app_bottom_navigation.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/services/health_analysis_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamaapp/models/health_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show pi;

class HealthProgressScreen extends StatefulWidget {
  const HealthProgressScreen({super.key});

  @override
  State<HealthProgressScreen> createState() => _HealthProgressScreenState();
}

class _HealthProgressScreenState extends State<HealthProgressScreen> {
  final ApiService _apiService = ApiService();
  final HealthAnalysisService _healthService = HealthAnalysisService();
  bool _isLoading = true;
  String _userName = '';
  String? _phoneNumber;
  HealthAnalysis? _currentAnalysis;
  List<HealthAnalysisLog> _healthHistory = [];
  DateTime? _lastAnalysisTime;

  @override
  void initState() {
    print('\n=== Health Progress Screen Initialization ===');
    super.initState();
    _loadPhoneNumber();
    _startHealthAnalysis();
    print('==========================\n');
  }

  @override
  void dispose() {
    print('\n=== Health Progress Screen Disposal ===');
    _healthService.stopPeriodicAnalysis();
    super.dispose();
    print('==========================\n');
  }

  Future<void> _startHealthAnalysis() async {
    print('\n=== Starting Health Analysis Service ===');
    await _healthService.startPeriodicAnalysis();
    _lastAnalysisTime = await _healthService.getLastAnalysisTime();
    print('Last analysis time: $_lastAnalysisTime');
    print('==========================\n');
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phone_number');
    print('\n=== Loading Phone Number ===');
    print('Phone Number: $phoneNumber');
    print('All SharedPreferences keys: ${prefs.getKeys()}');
    print('==========================\n');

    setState(() {
      _phoneNumber = phoneNumber;
    });

    if (phoneNumber != null) {
      await _loadHealthData();
    }
  }

  Future<void> _loadHealthData() async {
    if (_phoneNumber == null) {
      print('\n=== Health Data API Error ===');
      print('Error: Phone number is null');
      print('Cannot make API calls without phone number');
      print('================================\n');
      return;
    }

    print('\n=== Loading Health Data ===');
    print('Phone Number: $_phoneNumber');
    print('Last Analysis Time: $_lastAnalysisTime');

    try {
      setState(() => _isLoading = true);
      print('Loading state set to true');

      print('\n--- Health History API ---');
      print('Endpoint: /api/health/health/$_phoneNumber');
      print('Method: GET');
      print('Request Headers:');
      print('  - Content-Type: application/json');
      print('  - Authorization: Bearer [token]');

      final history = await _apiService.getHealthHistory(_phoneNumber!);
      print('\nResponse:');
      print('Status: Success');
      print('Number of entries: ${history.length}');

      if (history.isEmpty) {
        print('Warning: No health history entries found');
        print('This could mean:');
        print('1. No health analysis has been performed yet');
        print('2. The API returned an empty list');
        print('3. There was an error parsing the response');
      } else {
        print('Latest entry timestamp: ${history.first.timestamp}');
        print('Oldest entry timestamp: ${history.last.timestamp}');
        print('Number of entries: ${history.length}');
      }

      // Get the latest analysis from history
      if (history.isNotEmpty) {
        _currentAnalysis = history.first.analysis;
        print('\nLatest Analysis:');
        print('Health Score: ${_currentAnalysis!.healthScore}');
        print('Symptoms Found: ${_currentAnalysis!.symptomsFound.length}');
        print('Recommendations: ${_currentAnalysis!.recommendations.length}');
        print(
            'Analysis Timeframe: ${_currentAnalysis!.analysisTimeframeDays} days');
        print('Analyzed Queries: ${_currentAnalysis!.analyzedQueries}');
      } else {
        print('\nNo current analysis available');
        _currentAnalysis = null;
      }

      setState(() {
        _healthHistory = history;
        _isLoading = false;
      });
      print('\nState updated successfully');
    } catch (e) {
      print('\n=== Health Data API Error ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack trace: ${StackTrace.current}');

      setState(() {
        _isLoading = false;
        _currentAnalysis = null;
        _healthHistory = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading health data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    print('==========================\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCB4172),
        elevation: 0,
        title: const Text(
          'Health Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCB4172)),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSymptomsButtons(),
                  _buildHealthTrendIndicator(),
                  _buildHealthScoreChart(),
                  _buildHealthMetrics(),
                  _buildRecommendations(),
                ],
              ),
            ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildSymptomsButtons() {
    if (_currentAnalysis == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptoms logged this week',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentAnalysis!.symptomsFound.map((symptom) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCB4172).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: _getSeverityColor(symptom.severity),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${symptom.name} (${symptom.severity})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    if (_currentAnalysis == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_lastAnalysisTime != null)
                Text(
                  'Last Updated: ${_formatDateTime(_lastAnalysisTime!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildMetricCard(
                'Health Score',
                '${_currentAnalysis!.healthScore.toStringAsFixed(1)}',
                Icons.favorite,
              ),
              _buildMetricCard(
                'Symptoms',
                '${_currentAnalysis!.symptomsFound.length}',
                Icons.warning_amber_rounded,
              ),
              _buildMetricCard(
                'Recommendations',
                '${_currentAnalysis!.recommendations.length}',
                Icons.lightbulb_outline,
              ),
              _buildMetricCard(
                'History',
                '${_healthHistory.length}',
                Icons.history,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFCB4172), size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCB4172),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    if (_currentAnalysis == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._currentAnalysis!.recommendations.map(
            (rec) => _buildRecommendationItem(rec, Icons.check_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFCB4172)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity >= 7) return Colors.red;
    if (severity >= 5) return Colors.orange;
    if (severity >= 3) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildHealthScoreChart() {
    if (_healthHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _prepareChartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading chart data: ${snapshot.error}'),
          );
        }

        final dataPoints = snapshot.data ?? [];

        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wellness Score',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < dataPoints.length) {
                              final date = dataPoints[value.toInt()]
                                  ['middleDayDate'] as DateTime;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dataPoints.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            (entry.value['score'] as num).toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        color: const Color(0xFFCB4172),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFCB4172).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _prepareChartData() async {
    final dataPoints = await Future.wait(
      _healthHistory.map((log) async {
        final pregnancyWeek = await _calculatePregnancyWeek(log.timestamp);
        final middleDayDate = await _getMiddleDayOfWeek(log.timestamp);
        return {
          'week': pregnancyWeek,
          'score': log.analysis.healthScore,
          'middleDayDate': middleDayDate,
        };
      }),
    );

    // Sort by pregnancy week
    dataPoints.sort((a, b) => (a['week'] as int).compareTo(b['week'] as int));
    return dataPoints;
  }

  Future<int> _calculatePregnancyWeek(DateTime timestamp) async {
    // Get the pregnancy start date from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final pregnancyStartDateStr = prefs.getString('pregnancy_start_date');

    if (pregnancyStartDateStr == null) {
      return 0;
    }

    final pregnancyStartDate = DateTime.parse(pregnancyStartDateStr);
    final difference = timestamp.difference(pregnancyStartDate);
    final weeks = (difference.inDays / 7).floor();

    return weeks;
  }

  Future<DateTime> _getMiddleDayOfWeek(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final pregnancyStartDateStr = prefs.getString('pregnancy_start_date');

    if (pregnancyStartDateStr == null) {
      return timestamp;
    }

    final pregnancyStartDate = DateTime.parse(pregnancyStartDateStr);
    final difference = timestamp.difference(pregnancyStartDate);
    final weeks = (difference.inDays / 7).floor();

    // Calculate the middle day of the week (3 days after the start of the week)
    final weekStart = pregnancyStartDate.add(Duration(days: weeks * 7));
    final middleDay = weekStart.add(const Duration(days: 3));

    return middleDay;
  }

  Widget _buildHealthTrendIndicator() {
    if (_currentAnalysis == null) {
      return const SizedBox.shrink();
    }

    final healthScore = _currentAnalysis!.healthScore;
    final healthStatus = _getHealthStatus(healthScore);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Health Trend',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    // Health status segments
                    CustomPaint(
                      size: const Size(150, 150),
                      painter: HealthTrendPainter(
                        healthStatus: healthStatus,
                      ),
                    ),
                  ],
                ),
              ),
              // Legend
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('Needs Attention', Colors.red),
                  _buildLegendItem('Unstable', Colors.orange),
                  _buildLegendItem('Normal', Colors.yellow.shade700),
                  _buildLegendItem('Stable', Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<String?>(
            future: SharedPreferences.getInstance()
                .then((prefs) => prefs.getString('user_name')),
            builder: (context, snapshot) {
              String healthMessage = '';
              Color messageColor = Colors.black;

              switch (healthStatus) {
                case HealthStatus.needsAttention:
                  healthMessage = 'needs immediate attention';
                  messageColor = Colors.red;
                  break;
                case HealthStatus.unstable:
                  healthMessage = 'is unstable';
                  messageColor = Colors.orange;
                  break;
                case HealthStatus.normal:
                  healthMessage = 'is normal';
                  messageColor = Colors.yellow.shade700;
                  break;
                case HealthStatus.stable:
                  healthMessage = 'is stable';
                  messageColor = Colors.green;
                  break;
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(text: 'Your health '),
                      TextSpan(
                        text: healthMessage,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: messageColor,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  HealthStatus _getHealthStatus(double healthScore) {
    if (healthScore < 50) {
      return HealthStatus.needsAttention;
    } else if (healthScore < 70) {
      return HealthStatus.unstable;
    } else if (healthScore < 85) {
      return HealthStatus.normal;
    } else {
      return HealthStatus.stable;
    }
  }
}

enum HealthStatus {
  needsAttention,
  unstable,
  normal,
  stable,
}

class HealthTrendPainter extends CustomPainter {
  final HealthStatus healthStatus;

  HealthTrendPainter({required this.healthStatus});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    double startAngle = 0; // Start from the right side (0 degrees)

    // Draw all segments with varying percentages based on health status
    switch (healthStatus) {
      case HealthStatus.needsAttention:
        _drawSegment(
            canvas, center, radius, paint, Colors.red, startAngle, 0.4); // 40%
        startAngle += 2 * pi * 0.4;
        _drawSegment(canvas, center, radius, paint, Colors.orange, startAngle,
            0.3); // 30%
        startAngle += 2 * pi * 0.3;
        _drawSegment(canvas, center, radius, paint, Colors.yellow.shade700,
            startAngle, 0.2); // 20%
        startAngle += 2 * pi * 0.2;
        _drawSegment(canvas, center, radius, paint, Colors.green, startAngle,
            0.1); // 10%
        break;
      case HealthStatus.unstable:
        _drawSegment(
            canvas, center, radius, paint, Colors.red, startAngle, 0.2); // 20%
        startAngle += 2 * pi * 0.2;
        _drawSegment(canvas, center, radius, paint, Colors.orange, startAngle,
            0.4); // 40%
        startAngle += 2 * pi * 0.4;
        _drawSegment(canvas, center, radius, paint, Colors.yellow.shade700,
            startAngle, 0.3); // 30%
        startAngle += 2 * pi * 0.3;
        _drawSegment(canvas, center, radius, paint, Colors.green, startAngle,
            0.1); // 10%
        break;
      case HealthStatus.normal:
        _drawSegment(
            canvas, center, radius, paint, Colors.red, startAngle, 0.1); // 10%
        startAngle += 2 * pi * 0.1;
        _drawSegment(canvas, center, radius, paint, Colors.orange, startAngle,
            0.2); // 20%
        startAngle += 2 * pi * 0.2;
        _drawSegment(canvas, center, radius, paint, Colors.yellow.shade700,
            startAngle, 0.5); // 50%
        startAngle += 2 * pi * 0.5;
        _drawSegment(canvas, center, radius, paint, Colors.green, startAngle,
            0.2); // 20%
        break;
      case HealthStatus.stable:
        _drawSegment(
            canvas, center, radius, paint, Colors.red, startAngle, 0.05); // 5%
        startAngle += 2 * pi * 0.05;
        _drawSegment(canvas, center, radius, paint, Colors.orange, startAngle,
            0.1); // 10%
        startAngle += 2 * pi * 0.1;
        _drawSegment(canvas, center, radius, paint, Colors.yellow.shade700,
            startAngle, 0.25); // 25%
        startAngle += 2 * pi * 0.25;
        _drawSegment(canvas, center, radius, paint, Colors.green, startAngle,
            0.6); // 60%
        break;
    }
  }

  void _drawSegment(Canvas canvas, Offset center, double radius, Paint paint,
      Color color, double startAngle, double percentage) {
    paint.color = color.withOpacity(0.3);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      startAngle,
      2 * pi * percentage,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(HealthTrendPainter oldDelegate) {
    return oldDelegate.healthStatus != healthStatus;
  }
}
