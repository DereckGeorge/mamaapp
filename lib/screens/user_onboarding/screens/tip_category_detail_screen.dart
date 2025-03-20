import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/app_bottom_navigation.dart';
import 'package:mamaapp/models/mama_tip_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TipCategoryDetailScreen extends StatelessWidget {
  final TipCategory category;

  const TipCategoryDetailScreen({
    super.key,
    required this.category,
  });

  Future<void> _downloadTip(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadedTips = prefs.getStringList('downloaded_tips') ?? [];

      // Save category data
      final categoryData = json.encode({
        'id': category.id,
        'name': category.name,
        'contents': category.contents,
        'image': category.image,
      });

      if (!downloadedTips.contains(categoryData)) {
        downloadedTips.add(categoryData);
        await prefs.setStringList('downloaded_tips', downloadedTips);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tip downloaded successfully!'),
              backgroundColor: Color(0xFFCB4172),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tip already downloaded'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading tip: $e'),
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
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: Color(0xFFCB4172),
            ),
            onPressed: () => _downloadTip(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.image != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                        '${dotenv.env['APP_BASE_URL']}/${category.image!}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Markdown(
              data: category.contents,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
