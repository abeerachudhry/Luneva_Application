import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:luneva_application/theme/app_theme.dart';
import 'manual_meal_editor.dart';

class DietPlannerScreen extends StatefulWidget {
  const DietPlannerScreen({super.key});

  @override
  State<DietPlannerScreen> createState() => _DietPlannerScreenState();
}

class _DietPlannerScreenState extends State<DietPlannerScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  int? _manualCalories;
  bool _useSuggested = true;

  final List<Map<String, dynamic>> _meals = [
    {
      'time': '08:00 AM',
      'title': 'Breakfast',
      'items': ['Oats', 'Fruit', 'Yogurt'],
      'done': false
    },
    {
      'time': '12:30 PM',
      'title': 'Lunch',
      'items': ['Grilled chicken', 'Salad'],
      'done': false
    },
    {
      'time': '04:00 PM',
      'title': 'Snack',
      'items': ['Nuts', 'Green tea'],
      'done': false
    },
    {
      'time': '07:30 PM',
      'title': 'Dinner',
      'items': ['Salmon', 'Steamed veg'],
      'done': false
    },
  ];

  List<Map<String, dynamic>> _manualMeals = [];
  double _waterProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final today = _todayKey();

    if (doc.exists) {
      final data = doc.data()!;
      final lastDietReset = data['lastDietReset'] ?? '';
      List<dynamic> mealDone = data['dietPlannerMealsDone'] ?? [];
      if (lastDietReset != today) {
        mealDone = [];
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'dietPlannerMealsDone': [],
          'dietSessionsCompleted': 0,
          'lastDietReset': today,
        }, SetOptions(merge: true));
      }

      final lastWaterReset = data['lastWaterReset'] ?? '';
      int waterIntake = data['waterIntake'] ?? 0;
      if (lastWaterReset != today) {
        waterIntake = 0;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'waterIntake': 0,
          'lastWaterReset': today,
        }, SetOptions(merge: true));
      }

      setState(() {
        _waterProgress = waterIntake / 2500.0;
        for (int i = 0; i < _meals.length; i++) {
          _meals[i]['done'] = mealDone.contains(i);
        }
        if (data['manualDietPlan'] != null) {
          _manualMeals = List<Map<String, dynamic>>.from(data['manualDietPlan']);
        }
        _manualCalories = data['manualCalories'];
      });
    } else {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'dietPlannerMealsDone': [],
        'dietSessionsCompleted': 0,
        'waterIntake': 0,
        'lastDietReset': today,
        'lastWaterReset': today,
        'manualDietPlan': [],
        'manualCalories': 0,
      });
    }
  }

  Future<void> _toggleMeal(int index, bool isManual) async {
    setState(() {
      if (isManual) {
        _manualMeals[index]['done'] = !(_manualMeals[index]['done'] as bool? ?? false);
      } else {
        _meals[index]['done'] = !(_meals[index]['done'] as bool? ?? false);
      }
    });

    final doneIndexes = (_useSuggested ? _meals : _manualMeals)
        .asMap()
        .entries
        .where((e) => e.value['done'] as bool? ?? false)
        .map((e) => e.key)
        .toList();

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'dietPlannerMealsDone': doneIndexes,
      'dietSessionsCompleted': doneIndexes.length,
      'manualDietPlan': _manualMeals,
      'manualCalories': _manualCalories,
      'lastDietReset': _todayKey(),
    }, SetOptions(merge: true));
  }

  Future<void> _addWater(int ml) async {
    setState(() {
      _waterProgress = ((_waterProgress * 2500) + ml) / 2500.0;
      if (_waterProgress > 1) _waterProgress = 1;
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'waterIntake': (_waterProgress * 2500).round(),
      'lastWaterReset': _todayKey(),
    }, SetOptions(merge: true));

    if (_waterProgress >= 1) _showWaterCongrats();
  }

  void _showWaterCongrats() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Congratulations!', style: TextStyle(fontFamily: 'Montserrat')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://lottie.host/5012ee09-9c40-4693-b854-f9473083118b/P3g6cf3QXN.json',
              height: 150,
            ),
            const SizedBox(height: 12),
            const Text(
              'You have reached your daily water goal!\n\nStay hydrated to support PCOS health and well-being.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Exit', style: TextStyle(color: AppTheme.purple, fontFamily: 'Montserrat')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestedCalories = 2000;
    final dailyCalories =
        _useSuggested ? suggestedCalories : (_manualCalories ?? suggestedCalories);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diet Planner',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
Align(
  alignment: Alignment.center,
  child: SizedBox(
    width: MediaQuery.of(context).size.width * 0.9,
    child: const Text(
      'Plan your meals and track hydration daily.\nStay consistent to support your health goals.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      textAlign: TextAlign.center,
    ),
  ),
),

            const SizedBox(height: 20),

            Text(
              'Daily Calories',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: Text(
                    'Auto (${suggestedCalories} kcal)',
                    style: const TextStyle(fontFamily: 'Montserrat'),
                  ),
                  selected: _useSuggested,
                  onSelected: (s) => setState(() => _useSuggested = true),
                  selectedColor: AppTheme.purple.withOpacity(0.6),
                  backgroundColor: AppTheme.purple.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _useSuggested ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text(
                    'MANUAL',
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                  ),
                  selected: !_useSuggested,
                  onSelected: (s) async {
                    if (_manualMeals.isEmpty) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ManualMealEditor(meals: _manualMeals)),
                      );
                      if (result != null) {
                        final updatedMeals = List<Map<String, dynamic>>.from(result);
                        int totalCalories = 0;
                        for (var meal in updatedMeals) {
                          totalCalories += meal['calories'] as int? ?? 0;
                        }
                        await FirebaseFirestore.instance.collection('users').doc(uid).set({
                          'manualDietPlan': updatedMeals,
                          'manualCalories': totalCalories,
                          'lastDietReset': _todayKey(),
                        }, SetOptions(merge: true));
                        setState(() {
                          _manualMeals = updatedMeals;
                          _manualCalories = totalCalories;
                          _useSuggested = false;
                        });
                      }
                    } else {
                      setState(() {
                        _useSuggested = false;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Daily Plan • ${dailyCalories} kcal',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                ...(_useSuggested ? _meals : _manualMeals)
                    .asMap()
                    .entries
                    .map((e) {
                  final idx = e.key;
                  final meal = e.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.purple.withOpacity(0.5),
                    color: AppTheme.purple,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: SizedBox(
                        width: 50,
                        child: Lottie.network(
                          'https://lottie.host/34bf62b9-2a51-4db7-b921-a6a555b65646/eWfW93hnB6.json',
                          repeat: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        '${meal['title']} • ${meal['time']}',
                        style: const TextStyle(
                          // Keep original card text style (no Montserrat)
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        (meal['items'] as List).join(' • '),
                        style: const TextStyle(
                          // Keep original card text style (no Montserrat)
                          color: Colors.white70,
                        ),
                      ),
                      trailing: Checkbox(
                        value: meal['done'] as bool? ?? false,
                        onChanged: (_) => _toggleMeal(idx, !_useSuggested),
                        activeColor: Colors.white,
                        checkColor: AppTheme.purple,
                      ),
                    ),
                  );
                }).toList(),

                if (!_useSuggested && _manualMeals.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A39FF),
                          minimumSize: const Size(120, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          'Edit',
                          // Keep simple text here as well
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ManualMealEditor(meals: _manualMeals)),
                          );
                          if (result != null) {
                            final updatedMeals = List<Map<String, dynamic>>.from(result);
                            int totalCalories = 0;
                            for (var meal in updatedMeals) {
                              totalCalories += meal['calories'] as int? ?? 0;
                            }
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                              'manualDietPlan': updatedMeals,
                              'manualCalories': totalCalories,
                              'lastDietReset': _todayKey(),
                            }, SetOptions(merge: true));
                            setState(() {
                              _manualMeals = updatedMeals;
                              _manualCalories = totalCalories;
                            });
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Lottie.network(
                      'https://lottie.host/5012ee09-9c40-4693-b854-f9473083118b/P3g6cf3QXN.json',
                      width: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Water Intake',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(_waterProgress * 2500).round()} ml',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: _waterProgress,
                color: AppTheme.purple,
                backgroundColor: AppTheme.purple.withOpacity(0.1),
                minHeight: 18,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A39FF)),
                  onPressed: () => _addWater(200),
                  child: const Text('+200 ml'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A39FF)),
                  onPressed: () => _addWater(300),
                  child: const Text('+300 ml'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A39FF)),
                  onPressed: () => _addWater(500),
                  child: const Text('+500 ml'),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
