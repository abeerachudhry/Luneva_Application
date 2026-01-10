import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:luneva_application/theme/app_theme.dart';

class PhysicalTrainerScreen extends StatefulWidget {
  const PhysicalTrainerScreen({super.key});

  @override
  State<PhysicalTrainerScreen> createState() => _PhysicalTrainerScreenState();
}

class _PhysicalTrainerScreenState extends State<PhysicalTrainerScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String firstName = 'User';
  bool loadingName = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final fullName = doc.data()?['firstName'] ?? 'User';
      setState(() {
        firstName = fullName.isNotEmpty ? fullName : 'User';
        loadingName = false;
      });
    } else {
      setState(() {
        loadingName = false;
      });
    }
  }

  /// Save session with daily reset logic
  Future<void> _saveSession(int secondsSpent) async {
    final minutes = (secondsSpent / 60).ceil();
    if (minutes <= 0) return;

    final todayKey = _todayKey();
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await userRef.set({
      'trainerSessionsCompleted': {
        todayKey: FieldValue.increment(1),
      },
      'trainerTimeSpent': {
        todayKey: FieldValue.increment(minutes),
      },
    }, SetOptions(merge: true));
  }

  /// Helper to get today's key as yyyy-MM-dd
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _showExerciseModal({
    required String name,
    required String lottieUrl,
    required String description,
    int? fixedMinutes,
  }) {
    int selectedMinutes = fixedMinutes ?? 0;
    int remainingSeconds = selectedMinutes * 60;
    Timer? timer;
    bool running = false;
    int elapsedSeconds = 0;

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void stopTimer() {
              timer?.cancel();
              running = false;
              _saveSession(elapsedSeconds);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name completed! Amazing work 💪'),
                ),
              );
            }

            void startTimer(int minutes) {
              selectedMinutes = minutes;
              remainingSeconds = minutes * 60;
              elapsedSeconds = 0;
              running = true;

              timer?.cancel();
              timer = Timer.periodic(const Duration(seconds: 1), (_) {
                setModalState(() {
                  if (remainingSeconds > 0) {
                    remainingSeconds--;
                    elapsedSeconds++;
                  } else {
                    stopTimer();
                  }
                });
              });
              setModalState(() {}); // refresh modal state to show timer
            }

            final min = remainingSeconds ~/ 60;
            final sec = remainingSeconds % 60;

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Lottie.network(lottieUrl, height: 160),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  if (!running)
                    Wrap(
                      spacing: 12,
                      children: fixedMinutes == null
                          ? [5, 10, 15]
                              .map(
                                (m) => ElevatedButton(
                                  onPressed: () => startTimer(m),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.purple,
                                  ),
                                  child: Text('$m min'),
                                ),
                              )
                              .toList()
                          : [
                              ElevatedButton(
                                onPressed: () => startTimer(fixedMinutes),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.purple,
                                ),
                                child: const Text('Start Exercise'),
                              ),
                            ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: stopTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text('Stop'),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _exerciseCard({
    required String name,
    required String lottieUrl,
    required String description,
    int? fixedMinutes,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6A39FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(lottieUrl, height: 80),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showExerciseModal(
              name: name,
              lottieUrl: lottieUrl,
              description: description,
              fixedMinutes: fixedMinutes,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.purple,
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Physical Trainer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dear $firstName,',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Physical activity supports PCOS management by balancing hormones and improving '
              'insulin sensitivity. Short, consistent workouts improve energy and mood.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              children: [
                _exerciseCard(
                  name: 'Walk',
                  lottieUrl:
                      'https://lottie.host/6cc25404-c32e-45bd-919e-da324762124b/n788iOtra5.json',
                  description: 'Improves circulation and insulin regulation.',
                ),
                _exerciseCard(
                  name: 'Yoga',
                  lottieUrl:
                      'https://lottie.host/45dfd9e5-aac8-49eb-aed9-e82c1afaa714/6w0rem9SFA.json',
                  description: 'Calms nerves and balances hormones.',
                ),
                _exerciseCard(
                  name: 'Cycling',
                  lottieUrl:
                      'https://lottie.host/e9deeeca-aeed-4f1e-8ad9-1e99ddfacac3/mQULP3s3DQ.json',
                  description: 'Boosts metabolism and weight control.',
                ),
                _exerciseCard(
                  name: 'Planks',
                  lottieUrl:
                      'https://lottie.host/6dbf73d5-2fac-420b-bb39-b9b1a6150024/baF5RsV97K.json',
                  description: 'Strengthens core and posture.',
                  fixedMinutes: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
