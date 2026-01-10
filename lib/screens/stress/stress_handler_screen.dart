import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:luneva_application/theme/app_theme.dart';

class StressHandlerScreen extends StatefulWidget {
  const StressHandlerScreen({super.key});

  @override
  State<StressHandlerScreen> createState() => _StressHandlerScreenState();
}

class _StressHandlerScreenState extends State<StressHandlerScreen> {
  final List<String> quotes = const [
    'With PCOS, progress isn’t always linear — but every gentle step counts.',
    'You are more than your symptoms. Your strength grows with every choice to care for yourself.',
    'Small routines build big results. Hydrate, breathe, rest — your body notices.',
    'PCOS can be challenging, and you are allowed to rest. Recovery is also work.',
    'Consistency over perfection. Your kindness to yourself is your greatest tool.',
    'Your body is resilient. Celebrate the wins, learn from the dips, keep going.',
    'One day at a time. You’re building a life that supports your health.',
    'You are worthy of care, patience, and progress — even on rough days.',
  ];

  String _quoteForToday() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(seed);
    return quotes[rng.nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final todaysQuote = _quoteForToday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Handler', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.purple, AppTheme.purple.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Text(
                todaysQuote,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Stress with PCOS can ebb and flow. Gentle routines — breathwork, steady hydration, and consistent sleep — help your nervous system settle. Choose one small calming habit today and build from there.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _openAssistantSheet,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.purple,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Lottie.network(
                          'https://lottie.host/c5db9db7-c7b0-4aeb-928d-b229053006d9/zldJ2Yhhyv.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Stress Handling Assistant',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'A gentle AI companion to help navigate PCOS-related stress. Get calming prompts, routine ideas, and supportive check‑ins whenever you need them.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAssistantSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AssistantChatSheet(),
    );
  }
}

class _AssistantChatSheet extends StatefulWidget {
  const _AssistantChatSheet({super.key});

  @override
  State<_AssistantChatSheet> createState() => _AssistantChatSheetState();
}

class _AssistantChatSheetState extends State<_AssistantChatSheet> {
  final List<_ChatMessage> _chat = [
    _ChatMessage(sender: _Sender.assistant, text: 'Hi! I’m your Stress Handling Assistant. How are you feeling today?'),
  ];
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  late final GenerativeModel _model;
  late final ChatSession _session;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyCdBqEBQ27plwkeCkmrcrneVRJbHSeWpOE',  
    );
    _session = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.purple,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.self_improvement, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Stress Handling Assistant',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _chat.length,
                  itemBuilder: (context, index) {
                    final msg = _chat[index];
                    final isUser = msg.sender == _Sender.user;
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: isUser ? AppTheme.purple : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Ask about stress, PCOS routines, breathing, sleep...',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                                            ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: _sending ? null : _send,
                        child: _sending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chat.add(_ChatMessage(sender: _Sender.user, text: text));
      _sending = true;
    });
    _controller.clear();

    try {
      final response = await _session.sendMessage(Content.text(text));
      final reply = response.text ?? 'I’m here with you. Tell me more about how you’re feeling.';
      setState(() {
        _chat.add(_ChatMessage(sender: _Sender.assistant, text: reply));
      });
    } catch (e, st) {
      print('Gemini error: $e\n$st');
      setState(() {
        _chat.add(_ChatMessage(
          sender: _Sender.assistant,
          text: 'Something went wrong. Please try again.',
        ));
      });
    } finally {
      setState(() => _sending = false);
    }
  }
}

enum _Sender { user, assistant }

class _ChatMessage {
  final _Sender sender;
  final String text;
  _ChatMessage({required this.sender, required this.text});
}
