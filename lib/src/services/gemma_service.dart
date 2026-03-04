import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─── HF token key ─────────────────────────────────────────────────────────────
const String _kHfTokenKey = 'hf_token';

// Fallback token baked in via --dart-define=HF_TOKEN=hf_...
const String _kEnvHfToken = String.fromEnvironment('HF_TOKEN', defaultValue: '');

Future<String?> getStoredHfToken() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_kHfTokenKey);
  if (stored != null && stored.isNotEmpty) return stored;
  
  if (_kEnvHfToken.isNotEmpty) return _kEnvHfToken;
  
  // Try dotenv for local .env file
  final dotenvToken = dotenv.env['HF_TOKEN'];
  if (dotenvToken != null && dotenvToken.isNotEmpty) return dotenvToken;
  
  return null;
}

// ─── Emulator detection ────────────────────────────────────────────────────────

/// Returns true when running on an Android emulator or iOS Simulator.
/// On emulators, the XNNPACK native library in flutter_gemma will execute
/// ARM SME2 instructions (kai_get_sme_vector_length_u8) that are not
/// supported by the emulator CPU, causing a fatal SIGILL crash.
/// We detect this early and block all native model loading.
Future<bool> isRunningOnEmulator() async {
  try {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return !info.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return !info.isPhysicalDevice;
    }
  } catch (_) {}
  return false;
}

// Cached at app start to avoid repeated async calls
bool _emulatorCacheSet = false;
bool _cachedIsEmulator = false;

Future<bool> getIsEmulator() async {
  if (_emulatorCacheSet) return _cachedIsEmulator;
  _cachedIsEmulator = await isRunningOnEmulator();
  _emulatorCacheSet = true;
  return _cachedIsEmulator;
}

// ─── Device tier ──────────────────────────────────────────────────────────────

enum DeviceTier { high, mid, low }

class DeviceSpecs {
  final int ramGb;
  final String chipset;
  final DeviceTier tier;
  final bool isEmulator;

  const DeviceSpecs({
    required this.ramGb,
    required this.chipset,
    required this.tier,
    this.isEmulator = false,
  });
}

Future<DeviceSpecs> detectDeviceSpecs() async {
  final plugin = DeviceInfoPlugin();
  int ramMb = 0;
  String chipset = 'Unknown';
  bool emulator = false;

  if (Platform.isAndroid) {
    final info = await plugin.androidInfo;
    chipset = info.hardware;
    emulator = !info.isPhysicalDevice;
    // device_info_plus doesn't expose RAM directly on Android; use a heuristic
    // based on supported ABIs and board info — we fall back to 4 GB as baseline.
    ramMb = 4096;
  } else if (Platform.isIOS) {
    final info = await plugin.iosInfo;
    chipset = info.utsname.machine;
    emulator = !info.isPhysicalDevice;
    ramMb = 4096;
  }

  // Classify tier by available RAM
  final DeviceTier tier;
  if (ramMb >= 8192) {
    tier = DeviceTier.high;
  } else if (ramMb >= 4096) {
    tier = DeviceTier.mid;
  } else {
    tier = DeviceTier.low;
  }

  // Also cache the emulator flag
  _cachedIsEmulator = emulator;
  _emulatorCacheSet = true;

  return DeviceSpecs(
    ramGb: (ramMb / 1024).round(),
    chipset: chipset,
    tier: tier,
    isEmulator: emulator,
  );
}

// ─── Model Catalog ─────────────────────────────────────────────────────────────

enum ModelRecommendation { best, good, works, notRecommended }

class OfflineModelInfo {
  final String id;
  final String displayName;
  final String description;
  final String sizeLabel;
  final String hfRepo;
  final String filename;
  final bool gated;
  final ModelType modelType;
  // Minimum RAM (GB) to run smoothly
  final int minRamGb;
  // Ideal RAM (GB) for best performance
  final int idealRamGb;

  const OfflineModelInfo({
    required this.id,
    required this.displayName,
    required this.description,
    required this.sizeLabel,
    required this.hfRepo,
    required this.filename,
    this.gated = false,
    this.modelType = ModelType.gemmaIt,
    this.minRamGb = 2,
    this.idealRamGb = 4,
  });

  String get downloadUrl =>
      'https://huggingface.co/$hfRepo/resolve/main/$filename';

  ModelRecommendation recommendationFor(DeviceSpecs specs) {
    if (specs.ramGb >= idealRamGb) return ModelRecommendation.best;
    if (specs.ramGb >= minRamGb) return ModelRecommendation.good;
    if (specs.ramGb >= minRamGb - 1) return ModelRecommendation.works;
    return ModelRecommendation.notRecommended;
  }
}

const List<OfflineModelInfo> kOfflineModels = [
  // ── Gemma 3 1B int4 (Google, gated) — smallest + emulator-safe ───────────────
  // Uses dynamic_int4 QAT (no SME2), runs on emulator and physical devices.
  OfflineModelInfo(
    id: 'gemma3-1b-int4',
    displayName: 'Gemma 3 1B',
    description: 'Google · Latest gen · Best balance',
    sizeLabel: '~530 MB',
    hfRepo: 'litert-community/Gemma3-1B-IT',
    filename: 'gemma3-1b-it-int4.task',
    gated: true,
    modelType: ModelType.gemmaIt,
    minRamGb: 2,
    idealRamGb: 3,
  ),

  // ── Gemma 3 1B q8 (Google, gated) ───────────────────────────────────────────
  OfflineModelInfo(
    id: 'gemma3-1b-q8',
    displayName: 'Gemma 3 1B (q8)',
    description: 'Google · Higher quality · Physical device only',
    sizeLabel: '~1.0 GB',
    hfRepo: 'litert-community/Gemma3-1B-IT',
    filename: 'Gemma3-1B-IT_multi-prefill-seq_q8_ekv1280.task',
    gated: true,
    modelType: ModelType.gemmaIt,
    minRamGb: 3,
    idealRamGb: 4,
  ),

  // ── Gemma 2 2B (Google, gated) ───────────────────────────────────────────────
  OfflineModelInfo(
    id: 'gemma2-2b',
    displayName: 'Gemma 2 2B',
    description: 'Google · Strong reasoning · High quality',
    sizeLabel: '~2.0 GB',
    hfRepo: 'litert-community/Gemma2-2B-IT',
    filename: 'Gemma2-2B-IT_multi-prefill-seq_q8_ekv1280.task',
    gated: true,
    modelType: ModelType.gemmaIt,
    minRamGb: 4,
    idealRamGb: 6,
  ),

  // ── DeepSeek R1 1.5B (free, reasoning) ──────────────────────────────────────
  OfflineModelInfo(
    id: 'deepseek-r1-1b5',
    displayName: 'DeepSeek R1 1.5B',
    description: 'DeepSeek · Chain-of-thought reasoning · Free',
    sizeLabel: '~1.0 GB',
    hfRepo: 'litert-community/DeepSeek-R1-Distill-Qwen-1.5B',
    filename: 'DeepSeek-R1-Distill-Qwen-1.5B_multi-prefill-seq_q8_ekv1280.task',
    gated: false,
    modelType: ModelType.deepSeek,
    minRamGb: 3,
    idealRamGb: 4,
  ),

  // ── Phi-4 Mini (Microsoft, free) ─────────────────────────────────────────────
  OfflineModelInfo(
    id: 'phi4-mini',
    displayName: 'Phi-4 Mini',
    description: 'Microsoft · Best reasoning · High-end devices',
    sizeLabel: '~2.5 GB',
    hfRepo: 'litert-community/Phi-4-mini-instruct',
    filename: 'Phi-4-mini-instruct_multi-prefill-seq_q8_ekv1280.task',
    gated: false,
    modelType: ModelType.gemmaIt,
    minRamGb: 5,
    idealRamGb: 8,
  ),

  // ── Qwen 2.5 1.5B (Alibaba, free) ───────────────────────────────────────────
  OfflineModelInfo(
    id: 'qwen25-1b5',
    displayName: 'Qwen 2.5 1.5B',
    description: 'Alibaba · Multilingual · Everyday tasks',
    sizeLabel: '~1.0 GB',
    hfRepo: 'litert-community/Qwen2.5-1.5B-Instruct',
    filename: 'Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv1280.task',
    gated: false,
    modelType: ModelType.qwen,
    minRamGb: 3,
    idealRamGb: 4,
  ),
];

/// Returns models sorted best-to-worst for the given device specs.
List<OfflineModelInfo> rankedModelsFor(DeviceSpecs specs) {
  final scored = kOfflineModels.map((m) {
    final rec = m.recommendationFor(specs);
    final score = switch (rec) {
      ModelRecommendation.best => 3,
      ModelRecommendation.good => 2,
      ModelRecommendation.works => 1,
      ModelRecommendation.notRecommended => 0,
    };
    return (model: m, score: score);
  }).toList();

  scored.sort((a, b) => b.score.compareTo(a.score));
  return scored.map((e) => e.model).toList();
}

// ─── Per-model installed status ────────────────────────────────────────────────

/// FutureProvider family — returns true if the given model filename is installed.
final modelInstalledProvider =
    FutureProvider.family<bool, String>((ref, filename) async {
  return FlutterGemma.isModelInstalled(filename);
});

/// Preferences key ───────────────────────────────────────────────────────────
const _kSelectedModelKey = 'offline_model_id';

// ─── Device specs provider ─────────────────────────────────────────────────────
final deviceSpecsProvider = FutureProvider<DeviceSpecs>((ref) => detectDeviceSpecs());

// ─── Providers ─────────────────────────────────────────────────────────────────

final gemmaServiceProvider = Provider<GemmaService>((ref) => GemmaService());

final offlineModeProvider = StateProvider<bool>((ref) => false);

final selectedOfflineModelProvider =
    StateNotifierProvider<SelectedModelNotifier, OfflineModelInfo>(
  (ref) => SelectedModelNotifier(),
);

class SelectedModelNotifier extends StateNotifier<OfflineModelInfo> {
  SelectedModelNotifier() : super(kOfflineModels.first) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kSelectedModelKey);
    if (id != null) {
      final found = kOfflineModels.where((m) => m.id == id);
      if (found.isNotEmpty) state = found.first;
    }
  }

  Future<void> select(OfflineModelInfo model) async {
    state = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedModelKey, model.id);
  }
}

// ─── Download / model state ────────────────────────────────────────────────────

enum GemmaModelStatus {
  notDownloaded,
  downloading,
  ready,
  loading,
  error,
}

class GemmaModelState {
  final GemmaModelStatus status;
  final double progress;
  final String? errorMessage;

  const GemmaModelState({
    this.status = GemmaModelStatus.notDownloaded,
    this.progress = 0.0,
    this.errorMessage,
  });

  GemmaModelState copyWith({
    GemmaModelStatus? status,
    double? progress,
    String? errorMessage,
  }) =>
      GemmaModelState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

final gemmaModelStateProvider =
    StateNotifierProvider<GemmaModelStateNotifier, GemmaModelState>(
  (ref) => GemmaModelStateNotifier(
    ref.read(gemmaServiceProvider),
    ref,
  ),
);

class GemmaModelStateNotifier extends StateNotifier<GemmaModelState> {
  final GemmaService _service;
  final Ref _ref;

  GemmaModelStateNotifier(this._service, this._ref)
      : super(const GemmaModelState()) {
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final model = _ref.read(selectedOfflineModelProvider);
    final exists = await _service.isModelInstalled(model.filename);
    if (exists) {
      state = state.copyWith(status: GemmaModelStatus.ready);
    }
  }

  Future<void> downloadModel() async {
    final model = _ref.read(selectedOfflineModelProvider);

    state = state.copyWith(status: GemmaModelStatus.downloading, progress: 0.0);
    try {
      await _service.downloadModel(
        model: model,
        onProgress: (p) => state = state.copyWith(progress: p),
      );
      state = state.copyWith(status: GemmaModelStatus.ready, progress: 1.0);
      // Refresh per-model downloaded badges
      _ref.invalidate(modelInstalledProvider(model.filename));
    } catch (e) {
      state = state.copyWith(
        status: GemmaModelStatus.error,
        errorMessage: e.toString().split('\n').first,
      );
    }
  }

  Future<void> loadModel() async {
    state = state.copyWith(status: GemmaModelStatus.loading);
    try {
      final model = _ref.read(selectedOfflineModelProvider);
      await _service.initializeModel(model: model);
      state = state.copyWith(status: GemmaModelStatus.ready);
    } catch (e) {
      state = state.copyWith(
        status: GemmaModelStatus.error,
        errorMessage: 'Failed to load model: ${e.toString().split('\n').first}',
      );
    }
  }

  Future<void> deleteModel() async {
    final model = _ref.read(selectedOfflineModelProvider);
    await _service.deleteModel(filename: model.filename);
    state = const GemmaModelState(status: GemmaModelStatus.notDownloaded);
    // Refresh per-model downloaded badges
    _ref.invalidate(modelInstalledProvider(model.filename));
  }

  Future<void> onModelChanged() async {
    _service.unloadModel();
    state = const GemmaModelState();
    await _checkExisting();
  }
}

// ─── GemmaService ──────────────────────────────────────────────────────────────

class GemmaService {
  InferenceModel? _model;
  InferenceChat? _chat;

  /// modelId here is the full filename e.g. "gemma3-1b-it-int4.task"
  Future<bool> isModelInstalled(String modelId) async {
    return FlutterGemma.isModelInstalled(modelId);
  }

  /// Convenience: check by OfflineModelInfo
  Future<bool> isOfflineModelInstalled(OfflineModelInfo model) async {
    return FlutterGemma.isModelInstalled(model.filename);
  }

  Future<void> downloadModel({
    required OfflineModelInfo model,
    required void Function(double progress) onProgress,
  }) async {
    // Note: We bypass the emulator block here to allow testing the UI.
    // The load/initialize method will still block the emulator to prevent
    // the SIGILL crash.
    String? token;
    if (model.gated) {
      token = await getStoredHfToken();
      if (token == null || token.isEmpty) {
        throw Exception(
            'A HuggingFace token is required to download ${model.displayName}.\n'
            'Paste your token in the field above and try again.');
      }
    }
    await FlutterGemma.installModel(modelType: model.modelType)
        .fromNetwork(
          model.downloadUrl,
          token: token,
        )
        .withProgress((int percent) => onProgress(percent / 100.0))
        .install();
  }

  /// Re-registers the model as active (idempotent, no re-download) then loads it.
  Future<void> initializeModel({required OfflineModelInfo model}) async {
    // SAFETY: Never load native inference engine on emulator.
    // The bundled libllm_inference_engine_jni.so executes ARM SME2 instructions
    // (kai_get_sme_vector_length_u8) during XNNPACK init that are not supported
    // on the Android emulator CPU, causing a fatal SIGILL crash.
    if (await getIsEmulator()) {
      throw Exception(
        'Offline AI is not supported on the Android emulator or iOS Simulator.\n'
        'Please run on a physical device to use on-device AI.',
      );
    }
    if (_model != null) return;
    // Re-run install (idempotent) to ensure THIS model is the active one.
    String? token;
    if (model.gated) token = await getStoredHfToken();
    await FlutterGemma.installModel(modelType: model.modelType)
        .fromNetwork(model.downloadUrl, token: token)
        .install();
    _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
    _chat = await _model!.createChat(temperature: 0.8, topK: 40);
  }

  Future<String> sendMessage(String text) async {
    if (_model == null) throw Exception('Model not loaded');
    _chat ??= await _model!.createChat(temperature: 0.8, topK: 40);
    await _chat!.addQueryChunk(Message(text: text, isUser: true));
    final response = await _chat!.generateChatResponse();
    if (response is TextResponse) return response.token;
    return response.toString();
  }

  Future<void> clearChat() async {
    if (_model != null) {
      _chat = await _model!.createChat(temperature: 0.8, topK: 40);
    }
  }

  void unloadModel() {
    _model?.close();
    _model = null;
    _chat = null;
  }

  Future<void> deleteModel({required String filename}) async {
    unloadModel();
    try {
      await FlutterGemma.uninstallModel(filename);
    } catch (_) {}
  }
}
