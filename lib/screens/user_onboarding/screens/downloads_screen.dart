import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/app_bottom_navigation.dart';
import 'package:mamaapp/models/mama_tip_model.dart';
import 'tip_category_detail_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<TipCategory> _downloadedTips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedTips();
  }

  Future<void> _loadDownloadedTips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadedTips = prefs.getStringList('downloaded_tips') ?? [];

      setState(() {
        _downloadedTips = downloadedTips.map((tipString) {
          final tipMap = json.decode(tipString);
          return TipCategory(
            id: tipMap['id'],
            name: tipMap['name'],
            contents: tipMap['contents'],
            image: tipMap['image'],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading downloaded tips: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTip(TipCategory tip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadedTips = prefs.getStringList('downloaded_tips') ?? [];

      final tipData = json.encode({
        'id': tip.id,
        'name': tip.name,
        'contents': tip.contents,
        'image': tip.image,
      });

      downloadedTips.remove(tipData);
      await prefs.setStringList('downloaded_tips', downloadedTips);

      setState(() {
        _downloadedTips.remove(tip);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tip deleted successfully'),
            backgroundColor: Color(0xFFCB4172),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting tip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'Downloaded Tips',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedTips.isEmpty
              ? const Center(
                  child: Text('No downloaded tips yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _downloadedTips.length,
                  itemBuilder: (context, index) {
                    final tip = _downloadedTips[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: tip.image != null
                            ? Image.network(
                                '${dotenv.env['APP_BASE_URL']}/${tip.image!}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.article),
                        title: Text(tip.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: () => _deleteTip(tip),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TipCategoryDetailScreen(
                                category: tip,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
