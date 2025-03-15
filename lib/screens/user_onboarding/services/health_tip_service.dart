import 'dart:async';
import '../models/health_tip_model.dart';

class HealthTipService {
  // Mock data for categories
  final List<HealthTipCategory> _categories = [
    HealthTipCategory(
      id: 'postpartum-care',
      name: 'Postpartum care',
      iconPath: 'assets/birth_reps.png',
      description: 'Essential tips for recovery after childbirth',
    ),
    HealthTipCategory(
      id: 'safe-exercises',
      name: 'Safe exercises',
      iconPath: 'assets/pregnancy_discomforts.png',
      description: 'Gentle exercises safe for new mothers',
    ),
    HealthTipCategory(
      id: 'nutrition-tips',
      name: 'Nutrition tips',
      iconPath: 'assets/mom_guide.png',
      description: 'Healthy eating for mothers and babies',
    ),
    HealthTipCategory(
      id: 'mom-guide',
      name: 'Mom guide',
      iconPath: 'assets/nutrition_tips.png',
      description: 'Comprehensive guide for new mothers',
    ),
    HealthTipCategory(
      id: 'pregnancy-discomforts',
      name: 'Pregnancy discomforts',
      iconPath: 'assets/safe_exercises.png',
      description: 'Managing common pregnancy discomforts',
    ),
    HealthTipCategory(
      id: 'birth-preps',
      name: 'Birth preps',
      iconPath: 'assets/postpartum_care.png',
      description: 'Preparing for childbirth',
    ),
  ];

  // Mock data for health tips
  final List<HealthTip> _healthTips = [
    HealthTip(
      id: 'featured-tip-1',
      categoryId: 'nutrition-tips',
      title: 'Balanced Diet for Postpartum Recovery',
      summary: 'Learn about the essential nutrients needed for recovery after childbirth.',
      content: '''
# Balanced Diet for Postpartum Recovery

After giving birth, your body needs proper nutrition to heal and recover. A balanced diet is essential for your health and, if you're breastfeeding, for your baby's health too.

## Key Nutrients for Postpartum Recovery

### Protein
Protein is crucial for tissue repair and healing. Include lean meats, poultry, fish, eggs, dairy, legumes, and nuts in your diet.

### Iron
Blood loss during childbirth can deplete iron stores, leading to fatigue. Iron-rich foods include red meat, spinach, beans, and fortified cereals.

### Calcium
Calcium is essential for bone health, especially if you're breastfeeding. Dairy products, fortified plant milks, leafy greens, and calcium-set tofu are good sources.

### Vitamin C
Vitamin C aids in wound healing and iron absorption. Citrus fruits, strawberries, bell peppers, and broccoli are excellent sources.

### Omega-3 Fatty Acids
These support brain development in breastfed babies and may help prevent postpartum depression. Sources include fatty fish, walnuts, and flaxseeds.

## Meal Planning Tips

1. Prepare and freeze meals before delivery
2. Accept help with meal preparation from friends and family
3. Keep healthy snacks readily available
4. Stay hydrated by drinking plenty of water
5. Consider a multivitamin specifically designed for postpartum needs

Remember, every woman's nutritional needs are different. Consult with your healthcare provider for personalized advice.
''',
      imageUrl: 'assets/nutritiontips.png',
      publishedDate: DateTime(2023, 5, 15),
      isFeatured: true,
    ),
    HealthTip(
      id: 'tip-1',
      categoryId: 'postpartum-care',
      title: 'Managing Postpartum Bleeding',
      summary: 'What to expect and when to seek help for postpartum bleeding.',
      content: '''
# Managing Postpartum Bleeding

Postpartum bleeding, known as lochia, is a normal part of the recovery process after childbirth. Understanding what to expect can help you distinguish between normal bleeding and concerning symptoms.

## What is Lochia?

Lochia is the vaginal discharge after giving birth that consists of blood, mucus, and uterine tissue. It's your body's way of eliminating the extra blood and tissue that supported your pregnancy.

## Stages of Lochia

### Lochia Rubra (Days 1-3)
- Bright red bleeding, similar to a heavy period
- May contain small clots
- Heaviest immediately after delivery

### Lochia Serosa (Days 4-10)
- Pinkish or brownish color
- Thinner consistency
- Decreased volume

### Lochia Alba (Days 11-28 or longer)
- Yellowish-white or creamy color
- May last up to 6 weeks

## When to Seek Medical Help

Contact your healthcare provider immediately if you experience:
- Bleeding that soaks more than one pad per hour
- Large blood clots (bigger than a plum)
- Bleeding that increases rather than decreases
- Foul-smelling discharge
- Fever, chills, or severe abdominal pain

## Tips for Managing Postpartum Bleeding

1. Use maternity pads rather than tampons
2. Change pads regularly to prevent infection
3. Practice good hygiene
4. Rest when possible to reduce bleeding
5. Stay hydrated and maintain a nutritious diet

Remember that every woman's experience is different. If you have any concerns about your postpartum bleeding, don't hesitate to contact your healthcare provider.
''',
      imageUrl: 'assets/postpartum.png',
      publishedDate: DateTime(2023, 6, 10),
    ),
    HealthTip(
      id: 'tip-2',
      categoryId: 'safe-exercises',
      title: 'Gentle Postpartum Exercises',
      summary: 'Safe exercises to help your body recover after childbirth.',
      content: '''
# Gentle Postpartum Exercises

Returning to physical activity after childbirth should be gradual and gentle. These exercises can help strengthen your body and improve your well-being during the postpartum period.

## When to Start Exercising

- For vaginal births: You can begin gentle exercises a few days after delivery
- For cesarean births: Wait until your healthcare provider gives you clearance, typically 6-8 weeks

## Beneficial Gentle Exercises

### Pelvic Floor Exercises (Kegels)
1. Identify your pelvic floor muscles (the ones you use to stop urination)
2. Tighten these muscles and hold for 5-10 seconds
3. Release and relax for 5-10 seconds
4. Repeat 10 times, several times a day

### Deep Breathing
1. Sit or lie in a comfortable position
2. Place one hand on your chest and the other on your abdomen
3. Breathe in deeply through your nose, feeling your abdomen rise
4. Exhale slowly through your mouth
5. Repeat for 5-10 minutes

### Gentle Walking
- Start with short, 10-15 minute walks
- Gradually increase duration as you feel stronger
- Maintain good posture while walking

### Abdominal Compressions
1. Lie on your back with knees bent
2. Exhale and gently draw your belly button toward your spine
3. Hold for 5-10 seconds while breathing normally
4. Release and repeat 10 times

## Precautions

- Stop any exercise that causes pain
- Watch for increased bleeding, which may indicate you're doing too much
- Stay hydrated before, during, and after exercise
- Wear a supportive bra, especially if breastfeeding

Remember to consult with your healthcare provider before starting any exercise program after childbirth.
''',
      imageUrl: 'assets/safeexercises.png',
      publishedDate: DateTime(2023, 7, 5),
    ),
    HealthTip(
      id: 'tip-3',
      categoryId: 'mom-guide',
      title: 'Essential Guide for New Mothers',
      summary: 'A comprehensive guide to help you navigate the first few months of motherhood.',
      content: '''
# Essential Guide for New Mothers

The first few months of motherhood can be both rewarding and challenging. This guide provides essential information to help you navigate this new chapter in your life.

## Establishing a Routine

While newborns don't follow strict schedules, establishing loose routines can help create a sense of predictability:

- Feed your baby every 2-3 hours, or on demand
- Create a simple bedtime routine (bath, feed, gentle rocking)
- Try to sleep when your baby sleeps
- Accept that routines will change as your baby grows

## Self-Care for New Mothers

Taking care of yourself is crucial for your well-being and your ability to care for your baby:

- Rest whenever possible
- Stay hydrated and eat nutritious meals
- Accept help from family and friends
- Connect with other new parents
- Be gentle with yourself and adjust expectations

## When to Call Your Healthcare Provider

Contact your healthcare provider if you experience:

- Fever over 100.4°F (38°C)
- Heavy bleeding that soaks more than one pad per hour
- Severe pain not relieved by medication
- Feelings of harming yourself or your baby
- Difficulty breathing or chest pain
- Severe headache or changes in vision

Remember that every mother's journey is unique. Trust your instincts and don't hesitate to seek support when needed.
''',
      imageUrl: 'assets/mom_guide.png',
      publishedDate: DateTime(2023, 8, 15),
    ),
    HealthTip(
      id: 'tip-4',
      categoryId: 'pregnancy-discomforts',
      title: 'Managing Common Pregnancy Discomforts',
      summary: 'Tips and remedies for dealing with common discomforts during pregnancy.',
      content: '''
# Managing Common Pregnancy Discomforts

Pregnancy brings many changes to your body, and with those changes can come various discomforts. Here are some strategies to help manage common pregnancy discomforts.

## Morning Sickness

Despite its name, morning sickness can occur at any time of day:

- Eat small, frequent meals
- Keep crackers by your bed to eat before getting up
- Stay hydrated with small sips of water or ginger tea
- Avoid strong smells that trigger nausea
- Consider vitamin B6 supplements (after consulting your healthcare provider)

## Back Pain

As your pregnancy progresses, back pain is common due to weight changes and hormonal effects:

- Practice good posture
- Wear supportive shoes with low heels
- Use a maternity support belt
- Apply heat or cold to the painful area
- Sleep on your side with a pillow between your knees

## Heartburn

Hormonal changes and pressure from the growing uterus can cause heartburn:

- Eat smaller, more frequent meals
- Avoid spicy, greasy, or acidic foods
- Don't lie down immediately after eating
- Sleep with your upper body elevated
- Wear loose-fitting clothes

## Swelling

Some swelling (edema) is normal during pregnancy:

- Elevate your feet when sitting
- Avoid standing for long periods
- Wear comfortable, supportive shoes
- Stay hydrated
- Reduce sodium intake

Remember to discuss any persistent or severe symptoms with your healthcare provider.
''',
      imageUrl: 'assets/pregnancydiscomforts.png',
      publishedDate: DateTime(2023, 9, 20),
    ),
    HealthTip(
      id: 'tip-5',
      categoryId: 'birth-preps',
      title: 'Preparing for Childbirth',
      summary: 'Essential preparations and what to expect during labor and delivery.',
      content: '''
# Preparing for Childbirth

As your due date approaches, preparing for childbirth can help you feel more confident and ready for the big day.

## Creating a Birth Plan

A birth plan outlines your preferences for labor and delivery:

- Preferred pain management techniques
- Who you want present during labor
- Preferences for interventions
- Immediate postpartum wishes
- Remember that birth plans should be flexible, as circumstances may require adjustments

## Packing Your Hospital Bag

Consider packing these essentials:

- Important documents (ID, insurance card, hospital forms)
- Comfortable clothes for labor and recovery
- Toiletries and personal care items
- Nursing bras and pads if planning to breastfeed
- Outfit for baby to wear home
- Phone charger and camera

## Understanding the Stages of Labor

1. **First Stage**: Begins with contractions and ends when the cervix is fully dilated
   - Early labor: Cervix dilates to 3-4 cm
   - Active labor: Cervix dilates to 7-8 cm
   - Transition: Cervix dilates to 10 cm

2. **Second Stage**: Pushing and delivery of the baby

3. **Third Stage**: Delivery of the placenta

## Coping Techniques for Labor

- Breathing techniques
- Position changes
- Massage
- Hydrotherapy (shower or bath)
- Visualization and relaxation
- Support from a partner, doula, or birth companion

Remember that every birth is unique. Being informed and prepared while remaining flexible will help you navigate this transformative experience.
''',
      imageUrl: 'assets/birth_reps.png',
      publishedDate: DateTime(2023, 10, 5),
    ),
  ];

  // Get all categories
  Future<List<HealthTipCategory>> getCategories() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _categories;
  }

  // Get health tips by category
  Future<List<HealthTip>> getTipsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _healthTips.where((tip) => tip.categoryId == categoryId).toList();
  }

  // Get featured health tips
  Future<List<HealthTip>> getFeaturedTips() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _healthTips.where((tip) => tip.isFeatured).toList();
  }

  // Get health tip by ID
  Future<HealthTip?> getTipById(String tipId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _healthTips.firstWhere((tip) => tip.id == tipId);
    } catch (e) {
      return null;
    }
  }

  // Search health tips
  Future<List<HealthTip>> searchTips(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final lowercaseQuery = query.toLowerCase();
    return _healthTips.where((tip) {
      return tip.title.toLowerCase().contains(lowercaseQuery) ||
          tip.summary.toLowerCase().contains(lowercaseQuery) ||
          tip.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
} 