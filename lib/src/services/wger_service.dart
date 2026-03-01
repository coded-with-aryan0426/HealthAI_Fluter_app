import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ─── Models ──────────────────────────────────────────────────────────────────

class WgerExerciseImage {
  final int id;
  final String imageUrl;
  final bool isMain;

  const WgerExerciseImage({
    required this.id,
    required this.imageUrl,
    required this.isMain,
  });

  factory WgerExerciseImage.fromJson(Map<String, dynamic> j) => WgerExerciseImage(
        id: j['id'] as int? ?? 0,
        imageUrl: j['image'] as String? ?? '',
        isMain: j['is_main'] as bool? ?? false,
      );
}

class WgerExercise {
  final int id;
  final String name;
  final String? category;
  final List<WgerExerciseImage> images;
  final List<String> primaryMuscleNames;
  final List<String> secondaryMuscleNames;

  const WgerExercise({
    required this.id,
    required this.name,
    this.category,
    required this.images,
    required this.primaryMuscleNames,
    required this.secondaryMuscleNames,
  });

  /// All image URLs, main first
  List<String> get allImageUrls {
    final sorted = [...images]
      ..sort((a, b) => a.isMain == b.isMain ? 0 : a.isMain ? -1 : 1);
    return sorted.map((i) => i.imageUrl).where((u) => u.isNotEmpty).toList();
  }

  factory WgerExercise.fromInfoJson(Map<String, dynamic> j) {
    final translations =
        (j['translations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final enTrans =
        translations.where((t) => t['language'] == 2).toList();
    final name = enTrans.isNotEmpty
        ? (enTrans.first['name'] as String? ?? '')
        : '';

    String muscleName(Map<String, dynamic> m) =>
        (m['name_en'] as String?)?.isNotEmpty == true
            ? m['name_en'] as String
            : m['name'] as String? ?? '';

    return WgerExercise(
      id: j['id'] as int? ?? 0,
      name: name,
      category:
          (j['category'] as Map<String, dynamic>?)?['name'] as String?,
      images: ((j['images'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(WgerExerciseImage.fromJson)
          .where((i) => i.imageUrl.isNotEmpty)
          .toList(),
      primaryMuscleNames: ((j['muscles'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(muscleName)
          .where((s) => s.isNotEmpty)
          .toList(),
      secondaryMuscleNames:
          ((j['muscles_secondary'] as List?) ?? [])
              .cast<Map<String, dynamic>>()
              .map(muscleName)
              .where((s) => s.isNotEmpty)
              .toList(),
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

class WgerService {
  static const _base = 'https://wger.de';
  static const _timeout = Duration(seconds: 14);

  final _cache = <String, WgerExercise?>{};

  Future<WgerExercise?> findByName(String name) async {
    final key = name.toLowerCase().trim();
    if (_cache.containsKey(key)) return _cache[key];

    // Strategy 1: exact name match via translation search (most accurate)
    var result = await _searchByTranslation(key);

    // Strategy 2: search by first significant keyword if exact failed
    if (result == null) {
      result = await _searchByTranslation(_firstSignificantWord(key));
    }

    // Strategy 3: fallback to full-text term search with strict threshold
    if (result == null) {
      result = await _searchByTerm(key);
    }

    _cache[key] = result;
    return result;
  }

  /// Search using the translation endpoint — this matches exercise names
  /// directly instead of wger's popularity ranking.
  Future<WgerExercise?> _searchByTranslation(String name) async {
    if (name.isEmpty) return null;
    try {
      // Search English translations where name contains our query
      final uri = Uri.parse(
        '$_base/api/v2/exercise/search/?term=${Uri.encodeComponent(name)}'
        '&language=english&format=json',
      );
      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      // Response: { "suggestions": [ { "value": "...", "data": { "id": ..., "base_id": ... } } ] }
      final suggestions =
          (data['suggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      if (suggestions.isEmpty) return null;

      // Pick the suggestion whose name best matches ours
      WgerExercise? best;
      double bestScore = -1;

      for (final s in suggestions.take(10)) {
        final suggName = (s['value'] as String? ?? '').toLowerCase();
        final score = _similarity(name, suggName);
        if (score <= bestScore) continue;

        // Fetch the full exerciseinfo for this base_id
        final baseId = (s['data'] as Map<String, dynamic>?)?['base_id'];
        if (baseId == null) continue;

        final ex = await _fetchExerciseInfo(baseId as int);
        if (ex == null || ex.images.isEmpty) continue;

        bestScore = score;
        best = ex;
      }

      return (bestScore > 0) ? best : null;
    } catch (_) {
      return null;
    }
  }

  Future<WgerExercise?> _fetchExerciseInfo(int id) async {
    try {
      final uri = Uri.parse('$_base/api/v2/exerciseinfo/$id/?format=json');
      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return WgerExercise.fromInfoJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Fallback: full-text exerciseinfo search — returns by wger popularity
  /// so only use this with a high similarity threshold.
  Future<WgerExercise?> _searchByTerm(String term) async {
    if (term.isEmpty) return null;
    try {
      final uri = Uri.parse(
        '$_base/api/v2/exerciseinfo/?format=json&language=2&limit=15'
        '&term=${Uri.encodeComponent(term)}',
      );
      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final results =
          (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      WgerExercise? best;
      double bestScore = -1;

      for (final r in results) {
        final ex = WgerExercise.fromInfoJson(r);
        if (ex.images.isEmpty) continue;
        final score = _similarity(term, ex.name.toLowerCase());
        if (score > bestScore) {
          bestScore = score;
          best = ex;
        }
      }
      // Only use if score is decent — avoids returning totally unrelated exercises
      return (bestScore >= 0.2) ? best : null;
    } catch (_) {
      return null;
    }
  }

  String _firstSignificantWord(String name) {
    final words =
        name.split(RegExp(r'\s+')).where((w) => w.length > 3).toList();
    return words.isNotEmpty ? words.first : name.split(' ').first;
  }

  double _similarity(String a, String b) {
    final wa =
        a.split(RegExp(r'\W+')).where((s) => s.length > 1).toSet();
    final wb =
        b.split(RegExp(r'\W+')).where((s) => s.length > 1).toSet();
    if (wa.isEmpty || wb.isEmpty) return 0;
    final inter = wa.intersection(wb).length;
    final union = wa.union(wb).length;
    return union == 0 ? 0 : inter / union;
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final wgerServiceProvider =
    Provider<WgerService>((ref) => WgerService());

final wgerExerciseProvider =
    FutureProvider.family<WgerExercise?, String>((ref, name) {
  if (name.trim().isEmpty) return Future.value(null);
  return ref.read(wgerServiceProvider).findByName(name);
});
