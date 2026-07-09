/// Сервис для работы с API и WebSocket мессенджера Nexora.
/// Все экраны обращаются сюда. Базовый адрес меняется на твой деплой.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

const String kApiBase = 'https://nexora.onrender.com';
const String kWsUrl = 'wss://nexora.onrender.com/ws';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  Future<Map<String, dynamic>> requestCode(String email) async {
    final r = await http.post(
      Uri.parse('$kApiBase/api/request-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verify(String email, String code, String name) async {
    final r = await http.post(
      Uri.parse('$kApiBase/api/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'name': name}),
    );
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getRooms() async {
    final r = await http.get(Uri.parse('$kApiBase/api/rooms'));
    return jsonDecode(r.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createRoom(String name, String title) async {
    final r = await http.post(
      Uri.parse('$kApiBase/api/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'title': title}),
    );
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMessages(String room) async {
    final r = await http.get(Uri.parse('$kApiBase/api/messages?room=$room'));
    return jsonDecode(r.body) as List<dynamic>;
  }

  /// Открыть WebSocket-соединение для чата в реальном времени.
  WebSocketChannel connectWs() {
    return WebSocketChannel.connect(Uri.parse(kWsUrl));
  }
}
