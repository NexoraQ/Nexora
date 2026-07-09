import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:nexora/api.dart';
import 'package:nexora/session.dart';

class ChatScreen extends StatefulWidget {
  final String room;
  final String title;
  const ChatScreen({super.key, required this.room, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _msgs = [];
  final _text = TextEditingController();
  final _scroll = ScrollController();
  WebSocketChannel? _ws;
  bool _typing = false;
  String _typingWho = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _connect();
  }

  Future<void> _loadHistory() async {
    final list = await ApiService().getMessages(widget.room);
    if (mounted) setState(() => _msgs.addAll(list.cast<Map<String, dynamic>>()));
    _scrollToEnd();
  }

  void _connect() {
    _ws = ApiService().connectWs();
    _ws!.stream.listen((raw) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (m['type'] == 'chat' && m['room'] == widget.room) {
        if (mounted) {
          setState(() => _msgs.add(m.cast<String, dynamic>()));
          _scrollToEnd();
        }
      } else if (m['type'] == 'typing' && m['room'] == widget.room) {
        if (mounted) setState(() => {_typing = true, _typingWho = m['sender'] ?? ''});
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _typing = false);
        });
      }
    });
  }

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty || _ws == null) return;
    _ws!.sink.add(jsonEncode({
      'type': 'chat',
      'sender': Session().name,
      'text': t,
      'room': widget.room,
    }));
    _text.clear();
  }

  void _onType() {
    if (_ws != null) {
      _ws!.sink.add(jsonEncode({
        'type': 'typing',
        'sender': Session().name,
        'room': widget.room,
      }));
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _ws?.sink.close();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = Session().name;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(10),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                final mine = m['sender'] == me;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: mine ? const Color(0xFF7c5cff) : const Color(0xFF1a2042),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!mine)
                          Text(m['sender'] ?? '',
                              style: const TextStyle(color: Color(0xFF7c5cff), fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(m['text'] ?? '', style: const TextStyle(color: Colors.white)),
                        if (m['enc'] == true)
                          const Text('🔒', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_typing)
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 4),
              child: Text('$_typingWho печатает…', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    onChanged: (_) => _onType(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Сообщение…',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF0e1230),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
