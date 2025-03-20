import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mamaapp/screens/user_onboarding/screens/tip_category_detail_screen.dart';
import '../widgets/app_bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mamaapp/models/mama_tip_model.dart';

class HealthTipDetailScreen extends StatefulWidget {
  final int tipId;

  const HealthTipDetailScreen({super.key, required this.tipId});

  @override
  State<HealthTipDetailScreen> createState() => _HealthTipDetailScreenState();
}

class _HealthTipDetailScreenState extends State<HealthTipDetailScreen> {
  bool _isLoading = true;
  MamaTip? _tip;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTipDetails();
  }

  Future<void> _loadTipDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['APP_BASE_URL'] ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/mama-tips/${widget.tipId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tip = MamaTip.fromJson(data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load tip details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
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
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _tip == null
                  ? const Center(child: Text('Tip not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_tip!.image != null)
                            Container(
                              width: double.infinity,
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${dotenv.env['APP_BASE_URL']}/${_tip!.image!}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Text(
                            _tip!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCB4172),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _tip!.tipContent,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_tip!.categories.isNotEmpty) ...[
                            const Text(
                              'Tips',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCB4172),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: _tip!.categories.length,
                              itemBuilder: (context, index) {
                                final category = _tip!.categories[index];
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TipCategoryDetailScreen(
                                              category: category,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFCB4172),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (category.image != null)
                                              Image.network(
                                                '${dotenv.env['APP_BASE_URL']}/${category.image!}',
                                                height: 40,
                                                width: 40,
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              category.name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.download_outlined,
                                          color: Color(0xFFCB4172),
                                        ),
                                        onPressed: () async {
                                          try {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            final downloadedTips =
                                                prefs.getStringList(
                                                        'downloaded_tips') ??
                                                    [];

                                            // Save category data
                                            final categoryData = json.encode({
                                              'id': category.id,
                                              'name': category.name,
                                              'contents': category.contents,
                                              'image': category.image,
                                            });

                                            if (!downloadedTips
                                                .contains(categoryData)) {
                                              downloadedTips.add(categoryData);
                                              await prefs.setStringList(
                                                  'downloaded_tips',
                                                  downloadedTips);

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Tip downloaded successfully!'),
                                                    backgroundColor:
                                                        Color(0xFFCB4172),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Tip already downloaded'),
                                                    backgroundColor:
                                                        Colors.grey,
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error downloading tip: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
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
