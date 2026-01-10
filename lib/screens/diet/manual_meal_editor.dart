import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:luneva_application/theme/app_theme.dart';

class ManualMealEditor extends StatefulWidget {
  final List<Map<String, dynamic>> meals;
  const ManualMealEditor({super.key, required this.meals});

  @override
  State<ManualMealEditor> createState() => _ManualMealEditorState();
}

class _ManualMealEditorState extends State<ManualMealEditor> {
  late List<Map<String, dynamic>> meals;

  @override
  void initState() {
    super.initState();
    // Preserve state by copying existing meals or initializing default
    meals = widget.meals.isEmpty
        ? List.generate(2, (_) => {
              'title': 'Meal',
              'time': TimeOfDay.now().format(context),
              'items': ['Food item'],
              'calories': 0,
              'done': false,
            })
        : List<Map<String, dynamic>>.from(widget.meals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manual Meals',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// MANUAL LABEL
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MANUAL',
                  style: TextStyle(
                    color: AppTheme.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (_, i) {
                  final meal = meals[i];

                  return Card(
                    color: const Color(0xFF6A39FF),
                    elevation: 6,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Lottie Animation
                          SizedBox(
                            width: 55,
                            height: 55,
                            child: Lottie.network(
                              'https://lottie.host/34bf62b9-2a51-4db7-b921-a6a555b65646/eWfW93hnB6.json',
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Meal Name
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Meal Name',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  cursorColor: Colors.black,
                                  controller: TextEditingController(
                                      text: meal['title']),
                                  onChanged: (v) => meal['title'] = v,
                                ),

                                const SizedBox(height: 6), // spacing between fields

                                /// Items
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Foods (comma separated)',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  cursorColor: Colors.black,
                                  controller: TextEditingController(
                                      text: (meal['items'] as List).join(', ')),
                                  onChanged: (v) => meal['items'] =
                                      v.split(',').map((e) => e.trim()).toList(),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    /// Time
                                    GestureDetector(
                                      onTap: () async {
                                        final t = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (t != null) {
                                          setState(() {
                                            meal['time'] = t.format(context);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 14, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              meal['time'],
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    /// Calories (wider and number only)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.local_fire_department,
                                            size: 14,
                                            color: AppTheme.purple,
                                          ),
                                          const SizedBox(width: 4),
                                          SizedBox(
                                            width: 80, // wider input for calories
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              cursorColor: Colors.black,
                                              decoration: const InputDecoration(
                                                hintText: 'kcal',
                                                hintStyle: TextStyle(
                                                    color: Colors.black54),
                                                isDense: true,
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (v) =>
                                                  meal['calories'] = int.tryParse(v) ?? 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.purple.withOpacity(0.8)),
                    onPressed: () {
                      setState(() {
                        meals.add({
                          'title': 'Meal',
                          'time': TimeOfDay.now().format(context),
                          'items': ['Food item'],
                          'calories': 0,
                          'done': false,
                        });
                      });
                    },
                    child: const Text('Add Meal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple),
                    onPressed: () => Navigator.pop(context, meals),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
