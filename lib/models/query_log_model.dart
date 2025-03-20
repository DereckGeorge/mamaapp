class QueryLog {
  final String phoneNumber;
  final String query;
  final String response;
  final DateTime timestamp;
  final String? audioUrl;

  QueryLog({
    required this.phoneNumber,
    required this.query,
    required this.response,
    required this.timestamp,
    this.audioUrl,
  });

  factory QueryLog.fromJson(Map<String, dynamic> json) {
    return QueryLog(
      phoneNumber: json['phone_number'],
      query: json['query'],
      response: json['response'],
      timestamp: DateTime.parse(json['timestamp']),
      audioUrl: json['audio_url'],
    );
  }
}
