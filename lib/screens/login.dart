import 'package:flutter/material.dart';
import 'package:nexora/api.dart';
import 'package:nexora/session.dart';
import 'screens/rooms.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  String _msg = '';

  Future<void> _sendCode() async {
    setState(() => _loading = true);
    final d = await ApiService().requestCode(_email.text.trim());
    setState(() {
      _loading = false;
      _codeSent = d['ok'] == true;
      _msg = d['ok'] == true ? 'Код отправлен на почту ✅' : 'Ошибка: ${d['error']}';
    });
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    final d = await ApiService().verify(
      _email.text.trim(),
      _code.text.trim(),
      _name.text.trim().isEmpty ? 'Пользователь' : _name.text.trim(),
    );
    setState(() => _loading = false);
    if (d['ok'] == true) {
      await Session().save(d['token'], d['name'], d['userId']);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoomsScreen()),
        );
      }
    } else {
      setState(() => _msg = 'Ошибка: ${d['error']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a0e27), Color(0xFF151a35)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_rounded, size: 72, color: Color(0xFF7c5cff)),
                const SizedBox(height: 12),
                const Text('Nexora', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('Объединяя людей без границ',
                    style: TextStyle(color: Color(0xFF7c5cff), fontSize: 15)),
                const SizedBox(height: 28),
                if (!_codeSent) ...[
                  _field(_email, 'Email', false),
                  const SizedBox(height: 12),
                  _field(_name, 'Ваше имя', false),
                  const SizedBox(height: 18),
                  _button('Получить код', _sendCode),
                ] else ...[
                  _field(_code, 'Код из письма', false),
                  const SizedBox(height: 18),
                  _button('Войти', _verify),
                  TextButton(
                    onPressed: () => setState(() => _codeSent = false),
                    child: const Text('Изменить email',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
                if (_msg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_msg, style: const TextStyle(color: Colors.white70)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, bool pw) => TextField(
        controller: c,
        obscureText: pw,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF0e1230),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2a3158)),
          ),
        ),
      );

  Widget _button(String t, Future<void> Function() onTap) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : onTap,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(t),
        ),
      );
}
