import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:luneva_application/services/auth_service.dart';
import 'package:luneva_application/theme/app_theme.dart';
import 'package:luneva_application/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _ageCtl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _ageCtl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _loading = false);
      return;
    }

    try {
      final userCred = await AuthService.signUpWithEmail(
        email: _emailCtl.text.trim(),
        password: _passwordCtl.text,
      );

      final uid = userCred.user!.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

      Map<String, dynamic> userData = {
        'uid': uid,
        'name': _nameCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'onboarded': false, // ✅ ensure new users start with onboarding
      };

      final ageText = _ageCtl.text.trim();
      if (ageText.isNotEmpty) {
        final age = int.tryParse(ageText);
        if (age != null && age > 0 && age <= 120) userData['age'] = age;
      }

      await docRef.set(userData);

      if (!mounted) return;
      setState(() => _loading = false);
      _showSuccessDialog();

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} -> ${e.message}');
      if (e.code == 'email-already-in-use') {
        if (!mounted) return;
        setState(() => _loading = false);
        _showSuccessDialog();
      } else {
        setState(() {
          _loading = false;
          _error = AuthService.getMessageFromErrorCode(e.code);
        });
      }
    } catch (e, st) {
      debugPrint('Unexpected error: $e');
      debugPrint('$st');
      setState(() {
        _loading = false;
        _error = 'An unexpected error occurred. Please check console for details.';
      });
    }
  }

  void _goBackToLogin() {
    Navigator.of(context).pop();
  }

  void _showSuccessDialog() {
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
                          color: AppTheme.purple,
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
                  'Account Created!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome to Luneva',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      // ✅ route new users to onboarding
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/onboarding', (r) => false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.purple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.brightness_3, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text('Luneva',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.purple)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Create an account',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Join Luneva to track and manage your PCOS wellness journey',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _nameCtl,
                              label: 'Full name',
                              hintText: 'Your full name',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _emailCtl,
                              label: 'Email',
                              hintText: 'you@domain.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                final emailRegex =
                                    RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(v.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _passwordCtl,
                              label: 'Password',
                              hintText: 'Create a strong password',
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _ageCtl,
                              label: 'Age',
                              hintText: 'Your age (optional)',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final n = int.tryParse(v.trim());
                                if (n == null || n <= 0 || n > 120) {
                                  return 'Enter a valid age';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _createAccount,
                                child: const Text('Create Account'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: _goBackToLogin,
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: const TextStyle(color: Colors.black87),
                                    children: [
                                      TextSpan(
                                                                                text: 'Login',
                                        style: TextStyle(
                                          color: AppTheme.purple,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.network(
                        'https://assets9.lottiefiles.com/packages/lf20_x62chJ.json',
                        width: 160,
                        height: 160,
                        repeat: true,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Creating account...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
