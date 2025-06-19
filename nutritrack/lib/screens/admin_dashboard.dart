import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final dbRef = FirebaseDatabase.instance.ref();
  DateTime selectedDate = DateTime.now();
  int totalDikirim = 0;
  int totalDiterima = 0;
  double averageRating = 0;
  List<String> recommendations = [];
  Map<String, List<Map<String, dynamic>>> feedbackCategories = {};

  @override
  void initState() {
    super.initState();
    _fetchDataForDate(selectedDate);
  }

  void _fetchDataForDate(DateTime date) async {
    String tanggal = DateFormat('dd/MM/yyyy').format(date);
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final distribusiSnap = await dbRef.child('distribusi').get();
    final feedbackSnap = await dbRef.child('feedback').get();

    int dikirim = 0;
    int diterima = 0;
    List<Map<String, dynamic>> feedbacks = [];

    if (distribusiSnap.exists) {
      final data = distribusiSnap.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value['tanggal'] == tanggal) {
          dikirim += int.tryParse(value['jumlah'].toString()) ?? 0;
        }
      });
    }

    if (feedbackSnap.exists) {
      final data = feedbackSnap.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (key != 'auto_generated_id_1' && value is Map) {
          if (value['date'] == formattedDate) {
            diterima += int.tryParse(value['foodQuantity'].toString()) ?? 0;
          }
          feedbacks.add(Map<String, dynamic>.from(value));
        }
      });
    }

    // Analyze feedback data
    final analyzer = FeedbackAnalyzer(feedbacks);
    final avgRating = analyzer.calculateAverageRating();
    final recs = analyzer.generateRecommendations();
    final categories = analyzer.categorizeFeedback();

    setState(() {
      totalDikirim = dikirim;
      totalDiterima = diterima;
      averageRating = avgRating;
      recommendations = recs;
      feedbackCategories = categories;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchDataForDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF3E4),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            Text(
              'NutriTrack Dashboard',
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.orange),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                "Data tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate)}",
                style: const TextStyle(color: Colors.brown, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard("Dikirim", totalDikirim),
                  _statCard("Diterima", totalDiterima),
                  _statCard("Rating", averageRating, isRating: true),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Statistik Distribusi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (totalDikirim > totalDiterima ? totalDikirim : totalDiterima).toDouble() + 100,
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(toY: totalDikirim.toDouble(), color: Colors.orange),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(toY: totalDiterima.toDouble(), color: Colors.green),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Dikirim');
                              case 1:
                                return const Text('Diterima');
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildFeedbackAnalysis(),
              const SizedBox(height: 24),
              _buildRecommendations(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, dynamic value, {bool isRating = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRating ? value.toStringAsFixed(1) : value.toString(),
            style: TextStyle(
              color: isRating ? _getRatingColor(value) : Colors.orange,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isRating) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.star,
              color: _getRatingColor(value),
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }

  Widget _buildFeedbackAnalysis() {
    final totalFeedbacks = feedbackCategories.values.fold(0, (sum, list) => sum + list.length);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Analisis Feedback",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Distribusi Rating:"),
                    Text(
                      "Rata-rata: ${averageRating.toStringAsFixed(1)}",
                      style: TextStyle(
                        color: _getRatingColor(averageRating),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: totalFeedbacks > 0 
                      ? PieChart(
                          PieChartData(
                            sections: [
                              _buildPieSection('Excellent (5 stars)', Colors.green, totalFeedbacks),
                              _buildPieSection('Good (4 stars)', Colors.lightGreen, totalFeedbacks),
                              _buildPieSection('Average (3 stars)', Colors.orange, totalFeedbacks),
                              _buildPieSection('Poor (2 stars)', Colors.orangeAccent, totalFeedbacks),
                              _buildPieSection('Bad (1 star)', Colors.red, totalFeedbacks),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          ),
                        )
                      : const Center(child: Text("Tidak ada data feedback")),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PieChartSectionData _buildPieSection(String category, Color color, int total) {
    final count = feedbackCategories[category]?.length ?? 0;
    final percentage = total > 0 ? (count / total * 100) : 0;
    final rating = category.split(' ')[0]; // Extract the rating number

    return PieChartSectionData(
      value: count.toDouble(),
      color: color,
      title: '$rating\n${percentage.toStringAsFixed(0)}%',
      radius: 50,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  Widget _buildRecommendations() {
    if (recommendations.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rekomendasi Perbaikan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Berdasarkan feedback dengan rating rendah:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FeedbackAnalyzer {
  final List<Map<String, dynamic>> feedbackData;

  FeedbackAnalyzer(this.feedbackData);

  double calculateAverageRating() {
    if (feedbackData.isEmpty) return 0;
    
    double total = 0;
    for (var feedback in feedbackData) {
      total += (feedback['rating'] as int).toDouble();
    }
    return total / feedbackData.length;
  }

  String analyzeSentiment(String description) {
    final positiveWords = ['baik', 'enak', 'sangat', 'tepat', 'oke'];
    final negativeWords = ['rusak', 'kurang', 'lumayan', 'lumayan lah'];

    final lowerDesc = description.toLowerCase();

    int positiveCount = positiveWords.where((word) => lowerDesc.contains(word)).length;
    int negativeCount = negativeWords.where((word) => lowerDesc.contains(word)).length;

    if (positiveCount > negativeCount) return 'Positive';
    if (negativeCount > positiveCount) return 'Negative';
    return 'Neutral';
  }

  Map<String, List<Map<String, dynamic>>> categorizeFeedback() {
    final categories = <String, List<Map<String, dynamic>>>{
      'Excellent (5 stars)': [],
      'Good (4 stars)': [],
      'Average (3 stars)': [],
      'Poor (2 stars)': [],
      'Bad (1 star)': [],
    };

    for (var feedback in feedbackData) {
      final feedbackWithSentiment = Map<String, dynamic>.from(feedback);
      feedbackWithSentiment['sentiment'] = analyzeSentiment(feedback['description']);

      switch (feedback['rating']) {
        case 5:
          categories['Excellent (5 stars)']!.add(feedbackWithSentiment);
          break;
        case 4:
          categories['Good (4 stars)']!.add(feedbackWithSentiment);
          break;
        case 3:
          categories['Average (3 stars)']!.add(feedbackWithSentiment);
          break;
        case 2:
          categories['Poor (2 stars)']!.add(feedbackWithSentiment);
          break;
        case 1:
          categories['Bad (1 star)']!.add(feedbackWithSentiment);
          break;
      }
    }

    return categories;
  }

  List<String> generateRecommendations() {
    final recommendations = <String>[];
    final badFeedbacks = feedbackData.where((feedback) => feedback['rating'] <= 2).toList();

    if (badFeedbacks.isEmpty) {
      return ['Semua feedback positif. Pertahankan kualitas layanan!'];
    }

    for (var feedback in badFeedbacks) {
      final quality = feedback['foodQuality']?.toString() ?? '';
      if (quality.contains('Tidak Baik') || quality.contains('kurang')) {
        recommendations.add('Tingkatkan kualitas makanan (Feedback: "${feedback['description']}")');
      }
      final quantity = int.tryParse(feedback['foodQuantity'].toString()) ?? 0;
      if (quantity < 300) {
        recommendations.add('Perhatikan jumlah makanan yang dikirim (Hanya $quantity pada ${feedback['date']})');
      }
    }

    return recommendations;
  }
}