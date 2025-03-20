class HealthAnalysis {
  final double healthScore;
  final List<Symptom> symptomsFound;
  final List<String> recommendations;
  final int analyzedQueries;
  final int analysisTimeframeDays;
  final List<Map<String, dynamic>> conversationHistory;

  HealthAnalysis({
    required this.healthScore,
    required this.symptomsFound,
    required this.recommendations,
    required this.analyzedQueries,
    required this.analysisTimeframeDays,
    required this.conversationHistory,
  });

  factory HealthAnalysis.fromJson(Map<String, dynamic> json) {
    return HealthAnalysis(
      healthScore: (json['health_score'] as num).toDouble(),
      symptomsFound: (json['symptoms_found'] as List)
          .map((s) => Symptom.fromJson(s))
          .toList(),
      recommendations: List<String>.from(json['recommendations']),
      analyzedQueries: json['analyzed_queries'] as int,
      analysisTimeframeDays: json['analysis_timeframe_days'] as int,
      conversationHistory:
          List<Map<String, dynamic>>.from(json['conversation_history']),
    );
  }
}

class Symptom {
  final String name;
  final int severity;
  final String notes;

  Symptom({
    required this.name,
    required this.severity,
    required this.notes,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      name: json['name'] as String,
      severity: json['severity'] as int,
      notes: json['notes'] as String,
    );
  }
}

class HealthAnalysisLog {
  final String phoneNumber;
  final DateTime timestamp;
  final HealthAnalysis analysis;

  HealthAnalysisLog({
    required this.phoneNumber,
    required this.timestamp,
    required this.analysis,
  });

  factory HealthAnalysisLog.fromJson(Map<String, dynamic> json) {
    return HealthAnalysisLog(
      phoneNumber: json['phone_number'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      analysis: HealthAnalysis(
        healthScore: (json['health_score'] as num).toDouble(),
        symptomsFound: (json['symptoms_found'] as List)
            .map((s) => Symptom.fromJson(s))
            .toList(),
        recommendations: List<String>.from(json['recommendations']),
        analyzedQueries: json['analyzed_queries'] as int? ?? 0,
        analysisTimeframeDays: json['analysis_timeframe_days'] as int? ?? 7,
        conversationHistory: List<Map<String, dynamic>>.from(
            json['conversation_history'] as List? ?? []),
      ),
    );
  }
}
