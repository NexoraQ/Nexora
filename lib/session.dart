/// Сессия пользователя (хранится локально на устройстве).
library;

import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _kToken = 'token';
  static const _kName = 'name';
  static const _kUid = 'uid';

  String? email;
  String? name;
  String? userId;

  static final Session _i = Session._();
  factory Session() => _i;
  Session._();

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    email = p.getString(_kToken);
    name = p.getString(_kName);
    userId = p.getString(_kUid);
  }

  bool get isAuth => email != null && email!.isNotEmpty;

  Future<void> save(String email, String name, String userId) async {
    this.email = email;
    this.name = name;
    this.userId = userId;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, email);
    await p.setString(_kName, name);
    await p.setString(_kUid, userId);
  }

  Future<void> clear() async {
    email = name = userId = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kName);
    await p.remove(_kUid);
  }
}
