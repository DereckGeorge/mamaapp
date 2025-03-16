import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/health_tip_model.dart';
import '../services/health_tip_service.dart';
import '../widgets/app_bottom_navigation.dart';

class HealthTipDetailScreen extends StatefulWidget {
  final int tipId;

  const HealthTipDetailScreen({super.key, required this.tipId});

  @override
  State<HealthTipDetailScreen> createState() => _HealthTipDetailScreenState();
}

class _HealthTipDetailScreenState extends State<HealthTipDetailScreen> {
  final HealthTipService _healthTipService = HealthTipService();
  bool _isLoading = true;
  HealthTip? _tip;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTipDetails();
  }

  Future<void> _loadTipDetails() async {
    try {
      final tip = await _healthTipService.getTipById(widget.tipId.toString());
      
      setState(() {
        _tip = tip;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tip details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Health Tip',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB4172)))
          : _error != null
              ? Center(child: Text(_error!))
              : _tip == null
                  ? const Center(child: Text('Tip not found'))
                  : _buildTipContent(),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildTipContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tip!.imageUrl != null)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(_tip!.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Text(
            _tip!.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCB4172),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Published on ${_formatDate(_tip!.publishedDate)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _tip!.summary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Markdown(
            data: _tip!.content,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCB4172),
              ),
              h2: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              h3: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              p: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              listBullet: const TextStyle(
                fontSize: 16,
                color: Color(0xFFCB4172),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
