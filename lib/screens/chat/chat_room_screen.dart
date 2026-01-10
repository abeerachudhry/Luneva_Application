import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luneva_application/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  const ChatRoomScreen({super.key, required this.peerId, required this.peerName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _msgCtl = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String _chatId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  void dispose() {
    _msgCtl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtl.text.trim();
    if (text.isEmpty) return;

    final chatId = _chatId(uid, widget.peerId);
    final ref = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    await ref.add({
      'text': text,
      'senderId': uid,
      'receiverId': widget.peerId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _msgCtl.clear();
  }

  Widget _buildMessage(Map<String, dynamic> data) {
    final isMe = data['senderId'] == uid;
    final timestamp = data['createdAt'] != null
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.purple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              data['text'] ?? '',
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(timestamp),
              style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black45, fontSize: 9),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPeerAvatar(String peerId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(peerId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final avatarUrl = data?['profileImage'];
        return CircleAvatar(
          radius: 16,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          backgroundColor: Colors.grey.shade200,
          child: avatarUrl == null
              ? Text(
                  (data?['name'] ?? 'U')
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .take(2)
                      .join(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.purple, fontSize: 12),
                )
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatId = _chatId(uid, widget.peerId);
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.purple,
        title: Row(
          children: [
            _buildPeerAvatar(widget.peerId),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.peerName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildMessage(data);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtl,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.purple,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12)),
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
