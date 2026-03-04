import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final file = File('.env');
  final lines = await file.readAsLines();
  String token = '';
  for (final l in lines) {
    if (l.startsWith('HF_TOKEN=')) token = l.substring(9).trim();
  }

  final models = [
    'meta-llama/Llama-3.1-8B-Instruct',
    'Qwen/Qwen2.5-7B-Instruct',
    'microsoft/Phi-3.5-mini-instruct',
    'HuggingFaceH4/zephyr-7b-beta',
  ];

  for (final m in models) {
    print('Testing $m...');
    final res = await http.post(
      Uri.parse('https://router.huggingface.co/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': m,
        'messages': [
          {'role': 'system', 'content': 'You are HealthGuide AI.'},
          {'role': 'user', 'content': 'Hello'}
        ],
        'max_tokens': 50,
        'stream': false,
      }),
    );
    print('$m: ${res.statusCode}');
    if (res.statusCode != 200) print(res.body.substring(0, 100));
  }
}
