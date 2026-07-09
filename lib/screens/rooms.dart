import 'package:flutter/material.dart';
import 'package:nexora/api.dart';
import 'package:nexora/session.dart';
import 'screens/chat.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<dynamic> _rooms = [];
  bool _loading = true;
  final _newRoom = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await ApiService().getRooms();
    if (mounted) setState(() => {_rooms = r, _loading = false});
  }

  Future<void> _addRoom() async {
    final v = _newRoom.text.trim();
    if (v.isEmpty) return;
    await ApiService().createRoom(v, v);
    _newRoom.clear();
    _load();
  }

  Future<void> _logout() async {
    await Session().clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexora ⭐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newRoom,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Новая группа/канал',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF0e1230),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(onPressed: _addRoom, icon: const Icon(Icons.add)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _rooms.length,
                    itemBuilder: (_, i) {
                      final r = _rooms[i];
                      final isChannel = r['kind'] == 'channel';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF7c5cff),
                          child: Icon(isChannel ? Icons.campaign : Icons.forum, color: Colors.white),
                        ),
                        title: Text(r['title'] ?? r['name'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(isChannel ? 'Канал' : 'Группа',
                            style: const TextStyle(color: Colors.white54)),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ChatScreen(room: r['name'], title: r['title'])),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        color: const Color(0xFF151a35),
        padding: const EdgeInsets.all(10),
        child: Text('Ваш ID: ${Session().userId ?? '—'}',
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}
