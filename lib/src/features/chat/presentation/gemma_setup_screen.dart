import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../services/gemma_service.dart';

class GemmaSetupScreen extends ConsumerWidget {
  const GemmaSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelState = ref.watch(gemmaModelStateProvider);
    final selectedModel = ref.watch(selectedOfflineModelProvider);
    final deviceAsync = ref.watch(deviceSpecsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      body: deviceAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.dynamicMint),
        ),
        error: (_, __) => _SetupBody(
          modelState: modelState,
          selectedModel: selectedModel,
          specs: DeviceSpecs(ramGb: 4, chipset: 'Unknown', tier: DeviceTier.mid),
        ),
        data: (specs) {
          // Show a clear, permanent "not supported" screen on emulators.
          // The flutter_gemma native library crashes with SIGILL on any emulator
          // because it probes for ARM SME2 instructions the emulator doesn't have.
          if (specs.isEmulator) {
            return _EmulatorNotSupportedScreen();
          }
          return _SetupBody(
            modelState: modelState,
            selectedModel: selectedModel,
            specs: specs,
          );
        },
      ),
    );
  }
}

// ─── Emulator not-supported screen ───────────────────────────────────────────

class _EmulatorNotSupportedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.x,
                      color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.withValues(alpha: 0.12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(PhosphorIconsFill.warning,
                        color: Colors.orange, size: 36),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Not supported on emulator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'The on-device AI engine uses ARM CPU instructions '
                    'that are not available on the Android emulator.\n\n'
                    'Offline AI works on real Android devices. '
                    'Use the online AI while testing on the emulator.',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(PhosphorIconsFill.arrowLeft,
                          size: 16, color: AppColors.dynamicMint),
                      label: const Text('Back to chat',
                          style: TextStyle(color: AppColors.dynamicMint)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                            color: AppColors.dynamicMint.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Setup body ───────────────────────────────────────────────────────────────

class _SetupBody extends ConsumerWidget {
  final GemmaModelState modelState;
  final OfflineModelInfo selectedModel;
  final DeviceSpecs specs;

  const _SetupBody({
    required this.modelState,
    required this.selectedModel,
    required this.specs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranked = rankedModelsFor(specs);

    return SafeArea(
      child: Column(
        children: [
          // ── Top bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.x, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                // Device tier chip
                _DeviceTierChip(specs: specs),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero ──────────────────────────────────────────
                  _Hero(status: modelState.status, model: selectedModel),
                  const SizedBox(height: 28),

                  // ── Section label ─────────────────────────────────
                  Row(
                    children: [
                      Icon(PhosphorIconsFill.cpu,
                          color: Colors.grey.shade500, size: 13),
                      const SizedBox(width: 7),
                      Text(
                        'MODELS — RANKED FOR YOUR DEVICE',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Model list ────────────────────────────────────
                  _ModelList(
                    ranked: ranked,
                    selectedModel: selectedModel,
                    modelState: modelState,
                    specs: specs,
                  ),
                  const SizedBox(height: 20),

                    // ── Selected model info ───────────────────────────
                    _ModelInfoCard(model: selectedModel, specs: specs),
                    const SizedBox(height: 20),

                    // ── Status ────────────────────────────────────────
                  _StatusSection(state: modelState),
                  const SizedBox(height: 20),

                  // ── Action button ─────────────────────────────────
                  _ActionButton(state: modelState),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Device tier chip ─────────────────────────────────────────────────────────

class _DeviceTierChip extends StatelessWidget {
  final DeviceSpecs specs;
  const _DeviceTierChip({required this.specs});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (specs.tier) {
      DeviceTier.high => ('High-end device', const Color(0xFF34D399)),
      DeviceTier.mid => ('Mid-range device', const Color(0xFFFBBF24)),
      DeviceTier.low => ('Entry-level device', const Color(0xFFF87171)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final GemmaModelStatus status;
  final OfflineModelInfo model;
  const _Hero({required this.status, required this.model});

  @override
  Widget build(BuildContext context) {
    final isDownloading = status == GemmaModelStatus.downloading;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4A90D9).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90D9), AppColors.dynamicMint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90D9).withOpacity(0.4),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.memory_rounded, color: Colors.white, size: 34),
            )
                .animate(
                  onPlay: (c) => isDownloading ? c.repeat() : c.stop(),
                )
                .shimmer(duration: 1600.ms, color: Colors.white24),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Offline AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Runs 100% on-device · No internet · Full privacy',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0);
  }
}

// ─── Model List ───────────────────────────────────────────────────────────────

class _ModelList extends ConsumerWidget {
  final List<OfflineModelInfo> ranked;
  final OfflineModelInfo selectedModel;
  final GemmaModelState modelState;
  final DeviceSpecs specs;

  const _ModelList({
    required this.ranked,
    required this.selectedModel,
    required this.modelState,
    required this.specs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = modelState.status == GemmaModelStatus.downloading ||
        modelState.status == GemmaModelStatus.loading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: ranked.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          final isFirst = i == 0;
          final isLast = i == ranked.length - 1;

          return Column(
            children: [
              _ModelTile(
                model: m,
                isSelected: m.id == selectedModel.id,
                isLocked: isLocked,
                specs: specs,
                rank: i + 1,
                isFirst: isFirst,
                isLast: isLast,
                onTap: () async {
                  if (isLocked) return;
                  await ref.read(selectedOfflineModelProvider.notifier).select(m);
                  await ref.read(gemmaModelStateProvider.notifier).onModelChanged();
                },
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.04, end: 0);
  }
}

class _ModelTile extends ConsumerWidget {
  final OfflineModelInfo model;
  final bool isSelected;
  final bool isLocked;
  final DeviceSpecs specs;
  final int rank;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _ModelTile({
    required this.model,
    required this.isSelected,
    required this.isLocked,
    required this.specs,
    required this.rank,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec = model.recommendationFor(specs);
    final (recLabel, recColor) = _recInfo(rec);
    final isInstalledAsync = ref.watch(modelInstalledProvider(model.filename));
    final isDownloaded = isInstalledAsync.valueOrNull ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.dynamicMint.withOpacity(0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(20) : Radius.zero,
              bottom: isLast ? const Radius.circular(20) : Radius.zero,
            ),
          ),
          child: Row(
            children: [
              // Radio
              AnimatedContainer(
                duration: 200.ms,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.dynamicMint : Colors.white24,
                    width: isSelected ? 5 : 2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          Row(
                            children: [
                              Text(
                                model.displayName,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade300,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // FREE badge
                              if (!model.gated)
                                _Badge(label: 'FREE', color: AppColors.dynamicMint),
                              if (isDownloaded) ...[
                                const SizedBox(width: 4),
                                _Badge(
                                  label: 'DOWNLOADED',
                                  color: const Color(0xFF34D399),
                                ),
                              ],
                            ],
                          ),
                    const SizedBox(height: 3),
                    Text(
                      model.description,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Right side: size + recommendation
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    model.sizeLabel,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  _Badge(label: recLabel, color: recColor, small: false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _recInfo(ModelRecommendation rec) => switch (rec) {
        ModelRecommendation.best => ('BEST FIT', const Color(0xFF34D399)),
        ModelRecommendation.good => ('GOOD', const Color(0xFF60A5FA)),
        ModelRecommendation.works => ('WORKS', const Color(0xFFFBBF24)),
        ModelRecommendation.notRecommended =>
          ('LOW SPEC', const Color(0xFFF87171)),
      };
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _Badge({required this.label, required this.color, this.small = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 5 : 7, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── Model Info Card ──────────────────────────────────────────────────────────

class _ModelInfoCard extends StatelessWidget {
  final OfflineModelInfo model;
  final DeviceSpecs specs;
  const _ModelInfoCard({required this.model, required this.specs});

  @override
  Widget build(BuildContext context) {
    final rec = model.recommendationFor(specs);
    final (recLabel, recColor) = switch (rec) {
      ModelRecommendation.best => ('Best fit for your device', const Color(0xFF34D399)),
      ModelRecommendation.good => ('Good for your device', const Color(0xFF60A5FA)),
      ModelRecommendation.works => ('Works on your device', const Color(0xFFFBBF24)),
      ModelRecommendation.notRecommended =>
        ('May be slow on your device', const Color(0xFFF87171)),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: PhosphorIconsFill.sparkle,
            label: 'Device fit',
            value: recLabel,
            valueColor: recColor,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: PhosphorIconsFill.hardDrive,
            label: 'Download size',
            value: model.sizeLabel,
            valueColor: Colors.orange.shade300,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: PhosphorIconsFill.shield,
            label: 'Privacy',
            value: '100% on-device',
            valueColor: const Color(0xFF34D399),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: PhosphorIconsFill.wifiSlash,
            label: 'Works offline',
            value: 'Yes',
            valueColor: const Color(0xFF34D399),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.04, end: 0);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade400, size: 15),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ),
        Text(
          value,
          style: TextStyle(
              color: valueColor, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ─── Status Section ───────────────────────────────────────────────────────────

class _StatusSection extends ConsumerWidget {
  final GemmaModelState state;
  const _StatusSection({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.status) {
      GemmaModelStatus.notDownloaded => _StatusBadge(
          icon: PhosphorIconsFill.cloudArrowDown,
          label: 'Not downloaded',
          color: Colors.grey.shade500,
        ),
      GemmaModelStatus.downloading => _DownloadProgress(state: state),
      GemmaModelStatus.loading => _StatusBadge(
          icon: PhosphorIconsFill.circleNotch,
          label: 'Loading model into memory…',
          color: Colors.blue.shade300,
          spinning: true,
        ),
      GemmaModelStatus.ready => _StatusBadge(
          icon: PhosphorIconsFill.checkCircle,
          label: 'Model ready — offline AI active',
          color: const Color(0xFF34D399),
        ),
      GemmaModelStatus.error => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(PhosphorIconsFill.warning,
                  color: Colors.redAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.errorMessage ?? 'An error occurred.',
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
    };
  }
}

class _DownloadProgress extends StatelessWidget {
  final GemmaModelState state;
  const _DownloadProgress({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Downloading…',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            Text(
              '${(state.progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: AppColors.dynamicMint,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: state.progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.07),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.dynamicMint),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stay on Wi-Fi and keep the app open.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool spinning;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
    this.spinning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        spinning
            ? Icon(icon, color: color, size: 18)
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 1000.ms)
            : Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends ConsumerWidget {
  final GemmaModelState state;
  const _ActionButton({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(selectedOfflineModelProvider);

    return switch (state.status) {
      GemmaModelStatus.notDownloaded || GemmaModelStatus.error => _GradientButton(
          label: 'Download ${model.displayName}  ·  ${model.sizeLabel}',
          icon: PhosphorIconsFill.cloudArrowDown,
          onTap: () =>
              ref.read(gemmaModelStateProvider.notifier).downloadModel(),
        ),
      GemmaModelStatus.downloading => SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white38),
            ),
            label: const Text('Downloading…',
                style: TextStyle(color: Colors.white38)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      GemmaModelStatus.loading => const SizedBox.shrink(),
      GemmaModelStatus.ready => Column(
          children: [
            _GradientButton(
              label: 'Use Offline AI',
              icon: PhosphorIconsFill.sparkle,
              onTap: () {
                ref.read(offlineModeProvider.notifier).state = true;
                ref.read(gemmaModelStateProvider.notifier).loadModel();
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () =>
                  ref.read(gemmaModelStateProvider.notifier).deleteModel(),
              icon: const Icon(PhosphorIconsRegular.trash,
                  size: 15, color: Colors.redAccent),
              label: const Text('Delete model file',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
          ],
        ),
    };
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), AppColors.dynamicMint],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.04, end: 0);
  }
}
