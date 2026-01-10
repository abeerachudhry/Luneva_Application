import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:luneva_application/screens/chat/chat_room_screen.dart';
import 'package:luneva_application/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String _searchQuery = '';
  List<Map<String, dynamic>> _recentSearches = [];
  Map<String, dynamic>? _myUserData;

  @override
  void initState() {
    super.initState();
    _loadMyUserData();
  }

  Future<void> _loadMyUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        _myUserData = doc.data();
      });
    }
  }

  Widget _buildAvatar(Map<String, dynamic> data, {double radius = 24}) {
    final profileImage = data['profileImage'] as String?;
    final googlePhoto = data['googlePhotoUrl'] as String?;
    final avatarUrl = profileImage ?? googlePhoto;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Text(
              (data['name'] ?? 'U')
                  .split(' ')
                  .map((e) => e.isNotEmpty ? e[0] : '')
                  .take(2)
                  .join(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.purple,
                fontSize: radius / 2,
              ),
            )
          : null,
    );
  }

  // Add Friend page excludes already accepted friends, shows persistent tick for pending requests
  void _openAddFriendPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Add Friend',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.purple,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, meSnap) {
              if (!meSnap.hasData) return const Center(child: CircularProgressIndicator());
              final me = meSnap.data!.data() as Map<String, dynamic>;
              final myFriends = List<String>.from(me['friends'] ?? []);

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('friendRequests')
                    .where('from', isEqualTo: uid)
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, pendingSnap) {
                  final pendingDocs = pendingSnap.data?.docs ?? [];
                  final pendingToSet = pendingDocs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return (data['to'] as String);
                  }).toSet();

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, usersSnap) {
                      if (!usersSnap.hasData) return const Center(child: CircularProgressIndicator());
                      var docs = usersSnap.data!.docs
                          .where((d) => d.id != uid && !myFriends.contains(d.id))
                          .toList();

                      // Default A–Z
                      docs.sort((a, b) {
                        final aName = (a['name'] ?? '').toString().toLowerCase();
                        final bName = (b['name'] ?? '').toString().toLowerCase();
                        return aName.compareTo(bName);
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                            child: Text(
                              'Luneva Friends',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Browse users and send friend requests. Accepted friends are hidden here.',
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2 / 2.5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final peerId = docs[index].id;
                                final data = docs[index].data() as Map<String, dynamic>;
                                final isPending = pendingToSet.contains(peerId);

                                return Card(
                                  color: AppTheme.purple,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: data['profileImage'] != null
                                              ? NetworkImage(data['profileImage'])
                                              : null,
                                          radius: 40,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          data['name'] ?? 'User',
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        isPending
                                            ? const Icon(Icons.check_circle, color: Colors.white)
                                            : IconButton(
                                                icon: const Icon(Icons.person_add, color: Colors.white),
                                                onPressed: () async {
                                                  final myName = _myUserData?['name'] ??
                                                      FirebaseAuth.instance.currentUser?.displayName ??
                                                      uid;
                                                  final myPhoto =
                                                      _myUserData?['profileImage'] ?? _myUserData?['googlePhotoUrl'];

                                                  await FirebaseFirestore.instance
                                                      .collection('friendRequests')
                                                      .add({
                                                    'from': uid,
                                                    'fromName': myName,
                                                    'fromPhoto': myPhoto,
                                                    'to': peerId,
                                                    'status': 'pending',
                                                    'timestamp': FieldValue.serverTimestamp(),
                                                  });
                                                  // Persistent tick handled by stream pendingToSet
                                                },
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openFriendRequestsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('friendRequests')
              .where('to', isEqualTo: uid)
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No pending requests',
                    style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }
            final requests = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final fr = requests[index].data() as Map<String, dynamic>;
                final senderName = fr['fromName'] ?? fr['from'];
                final senderPhoto = fr['fromPhoto'] as String?;
                return Card(
                  color: AppTheme.purple.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: senderPhoto != null ? NetworkImage(senderPhoto) : null,
                      child: senderPhoto == null
                          ? Text(
                              senderName.toString().isNotEmpty ? senderName.toString()[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppTheme.purple, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(
                      senderName,
                      style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await requests[index].reference.update({'status': 'accepted'});
                            await FirebaseFirestore.instance.collection('users').doc(uid).update({
                              'friends': FieldValue.arrayUnion([fr['from']])
                            });
                            await FirebaseFirestore.instance.collection('users').doc(fr['from']).update({
                              'friends': FieldValue.arrayUnion([uid])
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await requests[index].reference.update({'status': 'declined'});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.purple,
        elevation: 2,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search chats...',
                hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                icon: Icon(Icons.search, color: Colors.black54, size: 20),
              ),
              onChanged: (v) {
                setState(() {
                  _searchQuery = v.toLowerCase();
                  if (v.isNotEmpty) {
                    _recentSearches.insert(0, {'name': v});
                    if (_recentSearches.length > 5) {
                      _recentSearches.removeLast();
                    }
                  }
                });
              },
            ),
          ),

          // RECENT SEARCHES
          if (_recentSearches.isNotEmpty)
            SizedBox(
              height: 70,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: _recentSearches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final search = _recentSearches[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchQuery = search['name'].toLowerCase();
                        _recentSearches.clear();
                      });
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.purple.withOpacity(0.2),
                          child: Text(
                            search['name'][0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.purple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          search['name'],
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // ACTIONS BAR: Add Friend + Friend Requests centered
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Friend'),
                  onPressed: _openAddFriendPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.mail),
                  label: const Text('Friend Requests'),
                  onPressed: _openFriendRequestsModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          // CHAT LIST with swipe-to-delete
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: usersRef.doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final me = snapshot.data!.data() as Map<String, dynamic>;
                final friends = List<String>.from(me['friends'] ?? []);

                return StreamBuilder<QuerySnapshot>(
                  stream: usersRef
                      .where(FieldPath.documentId, whereIn: friends.isEmpty ? ['dummy'] : friends)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs.where((d) {
                      final udata = d.data() as Map<String, dynamic>;
                      final name = (udata['name'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final d = docs[index];
                        final u = d.data() as Map<String, dynamic>;

                        final lastOnline =
                            u['lastOnline'] != null ? (u['lastOnline'] as Timestamp).toDate() : null;
                        final isOnline =
                            lastOnline != null ? DateTime.now().difference(lastOnline).inMinutes < 5 : false;

                        return Slidable(
                          key: ValueKey(d.id),
                          startActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Friend'),
                                      content: Text(
                                        "Do you want to delete ${u['name'] ?? 'this user'} from your friends list?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await usersRef.doc(uid).update({
                                      'friends': FieldValue.arrayRemove([d.id])
                                    });
                                    await usersRef.doc(d.id).update({
                                      'friends': FieldValue.arrayRemove([uid])
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${u['name'] ?? 'User'} removed from friends"),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.purple,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoomScreen(
                                      peerId: d.id,
                                      peerName: u['name'] ?? 'User',
                                    ),
                                  ),
                                );
                                setState(() {
                                  _recentSearches.clear();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        _buildAvatar(u, radius: 26),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                            radius: 6,
                                            backgroundColor: isOnline ? Colors.green : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            u['name'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if ((u['nickname'] ?? '').toString().isNotEmpty)
                                            Text(
                                              u['nickname'],
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          if ((u['description'] ?? '').toString().isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                u['description'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
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
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
