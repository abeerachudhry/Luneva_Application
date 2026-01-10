import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      fullNameController.text = data['name'] ?? '';
      nicknameController.text = data['nickname'] ?? '';
      descriptionController.text = data['description'] ?? '';
      birthdayController.text = data['dob'] ?? '';
      weightController.text = data['weight'] ?? '';
      setState(() {});
    }
  }

  Future<void> _selectBirthday() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) {
      setState(() {
        birthdayController.text = "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': fullNameController.text.trim(),
      'nickname': nicknameController.text.trim(),
      'description': descriptionController.text.trim(),
      'dob': birthdayController.text.trim(),
      'weight': weightController.text.trim(),
    });

    setState(() => isSaving = false);

    if (!mounted) return;

    // Lottie-style success dialog like signup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A39FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.check, color: Colors.white, size: 60),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Profile Updated!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your changes have been saved',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // close dialog
                      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A39FF)),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardField(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF4FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _avatar() {
    String name = fullNameController.text.trim().isEmpty ? 'User' : fullNameController.text.trim();
    String initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return CircleAvatar(
      radius: 80,
      backgroundColor: const Color(0xFF6A39FF),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _avatar(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A39FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCardField(
                        TextFormField(
                          controller: fullNameController,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            border: InputBorder.none,
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter full name' : null,
                        ),
                      ),
                      _buildCardField(
                        TextFormField(
                          controller: nicknameController,
                          decoration: const InputDecoration(
                            labelText: "Nickname",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      _buildCardField(
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      _buildCardField(
                        TextFormField(
                          controller: birthdayController,
                          readOnly: true,
                          onTap: _selectBirthday,
                          decoration: const InputDecoration(
                            labelText: "Birthday",
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      _buildCardField(
                        TextFormField(
                          controller: weightController,
                          decoration: const InputDecoration(
                            labelText: "Weight (kg)",
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A39FF),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save', style: TextStyle(fontSize: 18)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
