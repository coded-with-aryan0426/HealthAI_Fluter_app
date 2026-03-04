import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void main() async {
  final file = File('.env');
  final lines = await file.readAsLines();
  String token = '';
  for (final l in lines) {
    if (l.startsWith('GEMINI_API_KEY=')) token = l.substring(15).trim();
  }

  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: token,
  );

  final prompt = 'Say hi';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  print(response.text);
}
