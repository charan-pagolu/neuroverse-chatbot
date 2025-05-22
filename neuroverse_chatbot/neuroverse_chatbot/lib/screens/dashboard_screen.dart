import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neuroverse_chatbot/services/mood_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> last7Moods = [];
  List<String> moodPatterns = [];
  late ConfettiController _confettiController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _fetchMoodData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _fetchMoodData() async {
  setState(() => _isLoading = true);
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final service = MoodService();
  final moods = await service.fetchLast7Moods(userId);
  final patterns = await service.fetchMoodPatterns(userId);


    setState(() {
      last7Moods = moods;
      moodPatterns = patterns;
      _isLoading = false;
    });
    _confettiController.play();
  }

  List<FlSpot> _generateMoodTrendSpots() {
    return List.generate(last7Moods.length,
        (i) => FlSpot(i.toDouble(), _moodToValue(last7Moods[i])));
  }

  List<ScatterSpot> _generatePatternVolatilitySpots() {
    return List.generate(moodPatterns.length, (i) {
      final pattern = moodPatterns[i];
      double volatility = _calculateVolatility(pattern);
      return ScatterSpot(i.toDouble(), volatility,
          color: volatility > 0.5 ? Colors.redAccent : Colors.greenAccent,
          radius: 10);
    });
  }

  double _moodToValue(String mood) => mood.toLowerCase() == 'good' ? 1 : 0;

  double _calculateVolatility(String pattern) {
    if (pattern.length < 2) return 0;
    double changes = 0;
    for (int i = 1; i < pattern.length; i++) {
      if (pattern[i] != pattern[i - 1]) changes++;
    }
    return changes / (pattern.length - 1);
  }

  Map<String, int> _countMoodPatternTypes() {
    final summary = {
      'Stable': 0,
      'Unstable': 0,
      'Mixed': 0,
    };

    for (final pattern in moodPatterns) {
      final unique = pattern.split('').toSet();
      if (unique.length == 1) {
        summary['Stable'] = summary['Stable']! + 1;
      } else if (unique.length == pattern.length) {
        summary['Unstable'] = summary['Unstable']! + 1;
      } else {
        summary['Mixed'] = summary['Mixed']! + 1;
      }
    }

    return summary;
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final patternCounts = _countMoodPatternTypes();
    final total = patternCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];

    return patternCounts.entries.map((entry) {
      Color color;
      switch (entry.key) {
        case 'Stable':
          color = Colors.green.shade400;
          break;
        case 'Unstable':
          color = Colors.red.shade400;
          break;
        default:
          color = Colors.orange.shade400;
      }
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${(entry.value / total * 100).toStringAsFixed(1)}%',
        color: color,
        radius: 80,
        titleStyle: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildMoodTrendChart() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/lotus.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(
                    "7-Day Mood Trend",
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.5,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value == 1 ? 'Good 😊' : value == 0 ? 'Bad 😔' : '',
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Day ${value.toInt() + 1}',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: _generateMoodTrendSpots(),
                        color: Colors.blue.shade600,
                        barWidth: 5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 6,
                            color: Colors.blue.shade800,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400.withOpacity(0.4),
                              Colors.blue.shade100.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.blue.shade900.withOpacity(0.9),
                        getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'Day ${spot.x.toInt() + 1}: ${spot.y == 1 ? 'Good' : 'Bad'}',
                            GoogleFonts.urbanist(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodVolatilityScatterPlot() {
    // Generate scatter spots
    List<ScatterSpot> spots = [];
    for (int i = 0; i < moodPatterns.length; i++) {
      final pattern = moodPatterns[i];
      double volatility = _calculateVolatility(pattern);

      // Discretize volatility into 5 bins (0-20%, 20-40%, 40-60%, 60-80%, 80-100%)
      int volatilityBin = (volatility * 5).floor().clamp(0, 4);
      double yPos = volatilityBin.toDouble();

      // Map volatility to color gradient (red -> yellow -> green)
      Color dotColor;
      if (volatility < 0.2) {
        dotColor = Colors.green.shade400; // Low volatility
      } else if (volatility < 0.4) {
        dotColor = Colors.lightGreen.shade300;
      } else if (volatility < 0.6) {
        dotColor = Colors.yellow.shade300; // Neutral
      } else if (volatility < 0.8) {
        dotColor = Colors.orange.shade300;
      } else {
        dotColor = Colors.red.shade400; // High volatility
      }

      spots.add(ScatterSpot(i.toDouble(), yPos, color: dotColor, radius: 4));
    }

    // Custom widget for the color gradient bar
    Widget gradientBar = Container(
      height: 20,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.lightGreen,
            Colors.green,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mood Volatility Analysis",
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Track the volatility of mood patterns over time. Dots are shaded based on percentage of volatility.",
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "-100%",
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: gradientBar),
                const SizedBox(width: 8),
                Text(
                  "+100%",
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 2.0,
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: spots,
                  minX: -0.5,
                  maxX: moodPatterns.length.toDouble() - 0.5,
                  minY: -0.5,
                  maxY: 4.5,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            '0-20%',
                            '20-40%',
                            '40-60%',
                            '60-80%',
                            '80-100%',
                          ];
                          int index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Text(
                              labels[index],
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                      axisNameWidget: Text(
                        'Volatility',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      axisNameSize: 30,
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Pattern ${value.toInt() + 1}',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                      axisNameWidget: Text(
                        'Patterns',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      axisNameSize: 30,
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  scatterTouchData: ScatterTouchData(
                    enabled: true,
                    touchTooltipData: ScatterTouchTooltipData(
                      tooltipBgColor: Colors.black.withOpacity(0.8),
                      getTooltipItems: (ScatterSpot touchedSpot) {
                        return ScatterTooltipItem(
                          'Pattern ${touchedSpot.x.toInt() + 1}\nVolatility: ${(touchedSpot.y / 4 * 100).toStringAsFixed(1)}%',
                          textStyle: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/lotus.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(
                    "Mood Pattern Distribution",
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.2,
                child: PieChart(
                  PieChartData(
                    sections: _generatePieChartSections(),
                    centerSpaceRadius: 50,
                    sectionsSpace: 4,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          return;
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.blue.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/lotus.png', width: 40, height: 24),
                            const SizedBox(width: 12),
                            Text(
                              "Neuroverse Insights",
                              style: GoogleFonts.urbanist(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Lottie.asset(
                          'assets/images/Animation - 1745924731296.json',
                          width: 60,
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: _isLoading
                          ? Center(
                              child: Lottie.asset(
                                'assets/images/Animation - 1745924731296.json',
                                width: 100,
                                height: 100,
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Your Mood Analytics",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildMoodTrendChart(),
                                    _buildMoodVolatilityScatterPlot(),
                                    _buildPieChartSection(),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal.shade600,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.teal.withOpacity(0.4),
                                        ),
                                        onPressed: _fetchMoodData,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.refresh, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Refresh Insights",
                                              style: GoogleFonts.urbanist(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.02,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: [Colors.teal, Colors.blue, Colors.purple, Colors.green],
            ),
          ),
        ],
      ),
    );
  }
}