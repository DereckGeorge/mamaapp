import 'package:flutter/material.dart';
import '../models/health_tip_model.dart';
import '../services/health_tip_service.dart';
import 'health_tip_detail_screen.dart';

class HealthTipCategoryScreen extends StatefulWidget {
  final HealthTipCategory category;

  const HealthTipCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<HealthTipCategoryScreen> createState() => _HealthTipCategoryScreenState();
}

class _HealthTipCategoryScreenState extends State<HealthTipCategoryScreen> {
  final HealthTipService _healthTipService = HealthTipService();
  List<HealthTip> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);
    try {
      final tips = await _healthTipService.getTipsByCategory(widget.category.id);
      setState(() {
        _tips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading health tips: $e')),
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
          widget.category.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB4172)))
          : _tips.isEmpty
              ? const Center(
                  child: Text(
                    'No health tips available in this category',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Image
                      if (_tips.isNotEmpty && _tips[0].imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(_tips[0].imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      
                      // Main Description
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _getCategoryDescription(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Section Title
                      if (widget.category.id == 'safe-exercises')
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'MATERNAL FITNESS PLAN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFCB4172),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      
                      if (widget.category.id == 'nutrition-tips')
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'ESSENTIAL NUTRIENTS FOR PREGNANCY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFCB4172),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                      // Programs/Options Grid
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: _tips.length,
                          itemBuilder: (context, index) => _buildProgramCard(_tips[index]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _getCategoryDescription() {
    if (widget.category.id == 'safe-exercises') {
      return "Staying active during pregnancy is a wonderful way to support your health and your baby's well-being! Visit our safe exercises page for easy, doctor-approved exercises that are perfect for every stage of pregnancy. Whether it's gentle stretches to strengthen movements we've got you covered. Take small steps forward and stay stronger, more energized, and ready for each stage of your pregnancy journey. Start exploring and stay active with us today! 😊";
    } else if (widget.category.id == 'nutrition-tips') {
      return "Taking care of your nutrition during pregnancy is the best way to ensure you and your baby stay healthy and strong! Eating the right foods helps with baby growth, supports your energy levels, and gives your body what it needs to recover after childbirth. In the Mama App, we've got simple, easy-to-follow nutrition tips just for you. From healthy snacks to delicious meals packed with vitamins and minerals, exploring our nutrition section will guide you through making the best food choices. Let's make your pregnancy journey as strong and healthy as possible—start exploring now!";
    }
    return widget.category.description;
  }

  Widget _buildProgramCard(HealthTip tip) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthTipDetailScreen(tipId: int.parse(tip.id)),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tip.imageUrl != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    tip.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                tip.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 