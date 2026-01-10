import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:luneva_application/screens/chat/chat_list_screen.dart';
import 'package:luneva_application/screens/profile/profile_screen.dart';
import 'package:luneva_application/main.dart'; // for themeNotifier
import 'package:luneva_application/theme/app_theme.dart';
import 'package:luneva_application/theme/app_theme_dark.dart';
import 'dart:ui';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  int completedMeals = 0;
  int completedWorkouts = 0;
  int workoutMinutes = 0;
  int waterIntake = 0;
  String firstName = 'User';
  String profileImageUrl = '';
  String fullName = 'User';

  Map<String, int> weeklyWorkoutMinutes = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _listenDailyProgress();
  }

  void _listenDailyProgress() {
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;

      final todayKey = _todayKey();
      final sessionsMap =
          snap.data()?['trainerSessionsCompleted'] as Map<String, dynamic>? ?? {};
      final minutesMap =
          snap.data()?['trainerTimeSpent'] as Map<String, dynamic>? ?? {};

      setState(() {
        completedMeals =
            (snap.data()?['dietPlannerMealsDone'] as List?)?.length ?? 0;
        completedWorkouts = sessionsMap[todayKey] ?? 0;
        workoutMinutes = minutesMap[todayKey] ?? 0;
        waterIntake = snap.data()?['waterIntake'] ?? 0;
        weeklyWorkoutMinutes = _buildWeeklyMinutes(minutesMap);
      });
    });
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<String> _last7DaysKeys() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    });
  }

  Map<String, int> _buildWeeklyMinutes(Map<String, dynamic> minutesMap) {
    final result = <String, int>{};
    for (final key in _last7DaysKeys()) {
      result[key] = minutesMap[key] ?? 0;
    }
    return result;
  }

  Future<void> _fetchUserData() async {
    if (uid == null) return;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final fullNameData = userDoc.data()?['name'] ?? 'User';
    final imageUrl = userDoc.data()?['profileImage'] ?? '';

    setState(() {
      fullName = fullNameData;
      firstName = fullNameData.split(' ').first;
      profileImageUrl = imageUrl;
    });
  }

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  void _openProfileModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Text(
                              getInitials(fullName),
                              style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A39FF)),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),

                    // Random avatar generator
                    if (profileImageUrl.isEmpty)
                      GestureDetector(
                        onTap: () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            final seed = Random().nextInt(100000).toString();
                            final avatarUrl =
                                "https://api.dicebear.com/7.x/bottts/png?seed=$seed";

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'profileImage': avatarUrl});

                            setState(() {
                              profileImageUrl = avatarUrl;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: const Text(
                            'Set Profile Picture',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A39FF),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A39FF),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      final w = parts[0];
      final initials = w.substring(0, w.length >= 2 ? 2 : 1);
      return initials.toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildDrawer() {
    return SizedBox(
      width: 250,
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF6A39FF)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? Text(
                            getInitials(fullName),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A39FF)),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      firstName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  const Icon(Icons.person, color: Colors.white),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Diet Planner'),
              onTap: () => _navigateTo('/diet'),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Trainer'),
              onTap: () => _navigateTo('/trainer'),
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: const Text('Stress Handler'),
              onTap: () => _navigateTo('/stress'),
            ),

            // NEW: Dark Mode toggle above Sign Out
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (enabled) {
                LunevaApp.themeNotifier.value =
                    enabled ? AppThemeDark.darkTheme : AppTheme.lightTheme;
              },
            ),

            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A39FF),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Luneva',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openProfileModal,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? Text(
                        getInitials(fullName),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A39FF),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, $firstName 👋",
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text("Here's your progress today:",
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _progressCard(
                      'https://lottie.host/892d4e4e-c874-4c49-958c-bbc7d5253a4e/JrkStZDMkM.json',
                      'Completed',
                      '$completedWorkouts Workouts',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _progressCard(
                      'https://lottie.host/7708611f-9290-4da9-b5f5-32fb0083518a/0e3ZHRVaPI.json',
                      'Meals',
                      '$completedMeals Done',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _progressCard(
                      'https://lottie.host/ba4e6525-8d4e-439f-b840-857b6bbd41a6/lsKj1a357p.json',
                      'Time Spent',
                      '$workoutMinutes min',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              _weeklySummaryCard(),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _appCard(
                      icon: Icons.local_drink,
                      title: 'Hydration',
                      subtitle: '$waterIntake ml today',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _appCard(
                      icon: Icons.restaurant_menu,
                      title: 'Meals',
                      subtitle: '$completedMeals completed',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text('Discover Modules',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat')),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _moduleCard('Diet Planner', '4 Meals', '2000 kcal', '🍽️', '/diet'),
                    _moduleCard('Trainer', '10 Exercises', '$workoutMinutes min', '🏋️‍♂️', '/trainer'),
                    _moduleCard('Stress Handler', '3 Sessions', 'Relax & Breathe', '🧘‍♀️', '/stress'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cards and helper widgets remain unchanged except for explicit text colors in module cards
  Widget _progressCard(String lottieUrl, String label, String value) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6A39FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(lottieUrl, width: 70, height: 70),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat')),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Montserrat')),
        ],
      ),
    );
  }

  Widget _moduleCard(
      String title, String subtitle, String detail, String emoji, String route) {
    return GestureDetector(
      onTap: () => _navigateTo(route),
      child: Container(
        width: 170,
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)), // force dark text
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black)), // force dark text
            Text(detail,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54)), // force dark grey
          ],
        ),
      ),
    );
  }

  Widget _weeklySummaryCard() {
    final maxValue = weeklyWorkoutMinutes.values.isEmpty
        ? 1
        : weeklyWorkoutMinutes.values.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Workout Minutes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: Colors.black, // force dark text
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyWorkoutMinutes.entries.map((entry) {
              final barHeight = maxValue == 0
                  ? 6.0
                  : (entry.value / maxValue) * 120;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: barHeight,
                      width: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A39FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.key.substring(8),
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Montserrat',
                        color: Colors.black, // force dark text
                      ),
                    ),
                    Text(
                      '${entry.value}m',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54, // force dark grey
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _appCard(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6A39FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

