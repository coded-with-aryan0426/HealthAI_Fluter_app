import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final file = File('/Volumes/Aryan/HealthAI/.env');
  final lines = await file.readAsLines();
  String token = '';
  for (final l in lines) {
    if (l.startsWith('GEMINI_API_KEY=')) token = l.substring(15).trim();
  }

  final res = await http.get(
    Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$token'),
  );
  print(res.statusCode);
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    for (final m in data['models']) {
      final name = m['name'];
      if (name.toString().contains('flash')) print(name);
    }
  } else {
    print(res.body);
  }
}
