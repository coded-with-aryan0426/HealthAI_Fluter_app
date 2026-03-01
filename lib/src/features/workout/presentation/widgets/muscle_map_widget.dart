import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maps exercise muscle group names to SVG element IDs in body_front.svg / body_back.svg
const _frontMuscleIds = {
  'chest': ['chest_left', 'chest_right'],
  'pectorals': ['chest_left', 'chest_right'],
  'shoulders': ['left_shoulder', 'right_shoulder'],
  'delts': ['left_shoulder', 'right_shoulder'],
  'front delts': ['left_shoulder', 'right_shoulder'],
  'biceps': ['left_bicep', 'right_bicep'],
  'forearms': ['left_forearm', 'right_forearm'],
  'abdominals': ['abs_1l', 'abs_1r', 'abs_2l', 'abs_2r', 'abs_3l', 'abs_3r'],
  'abs': ['abs_1l', 'abs_1r', 'abs_2l', 'abs_2r', 'abs_3l', 'abs_3r'],
  'core': ['abs_1l', 'abs_1r', 'abs_2l', 'abs_2r', 'abs_3l', 'abs_3r'],
  'obliques': ['left_oblique', 'right_oblique'],
  'quadriceps': ['left_quad', 'right_quad'],
  'quads': ['left_quad', 'right_quad'],
  'calves': ['left_calf', 'right_calf'],
  'hip flexors': ['hip'],
  'traps': ['traps'],
  'trapezius': ['traps'],
};

const _backMuscleIds = {
  'lats': ['lats_left', 'lats_right'],
  'latissimus dorsi': ['lats_left', 'lats_right'],
  'middle back': ['middle_back'],
  'rhomboids': ['middle_back'],
  'back': ['lats_left', 'lats_right', 'middle_back'],
  'upper back': ['traps', 'middle_back'],
  'lower back': ['lower_back'],
  'erectors': ['lower_back'],
  'traps': ['traps'],
  'trapezius': ['traps'],
  'triceps': ['left_tricep', 'right_tricep'],
  'glutes': ['glutes_left', 'glutes_right'],
  'hamstrings': ['left_hamstring', 'right_hamstring'],
  'calves': ['left_calf', 'right_calf'],
  'shoulders': ['left_shoulder', 'right_shoulder'],
  'rear delts': ['left_shoulder', 'right_shoulder'],
  'forearms': ['left_forearm', 'right_forearm'],
};

class MuscleMapWidget extends StatefulWidget {
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final Color primaryColor;
  final Color secondaryColor;
  final double height;
  final bool allowFlip;

  const MuscleMapWidget({
    super.key,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    this.primaryColor = const Color(0xFF6C63FF),
    this.secondaryColor = const Color(0xFF3A3A6A),
    this.height = 260,
    this.allowFlip = true,
  });

  @override
  State<MuscleMapWidget> createState() => _MuscleMapWidgetState();
}

class _MuscleMapWidgetState extends State<MuscleMapWidget>
    with SingleTickerProviderStateMixin {
  bool _showBack = false;
  String? _frontSvg;
  String? _backSvg;
  late AnimationController _flipCtrl;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _loadSvgs();
  }

  Future<void> _loadSvgs() async {
    final front = await rootBundle.loadString('assets/svg/body_front.svg');
    final back = await rootBundle.loadString('assets/svg/body_back.svg');
    if (!mounted) return;
    setState(() {
      _frontSvg = _colorize(front, _frontMuscleIds);
      _backSvg = _colorize(back, _backMuscleIds);
    });
  }

  String _colorize(String svg, Map<String, List<String>> muscleMap) {
    final primary = widget.primaryMuscles.map((m) => m.toLowerCase().trim()).toList();
    final secondary = widget.secondaryMuscles.map((m) => m.toLowerCase().trim()).toList();

    final primaryIds = <String>{};
    final secondaryIds = <String>{};

    for (final m in primary) {
      for (final key in muscleMap.keys) {
        if (m.contains(key) || key.contains(m)) {
          primaryIds.addAll(muscleMap[key]!);
        }
      }
    }
    for (final m in secondary) {
      for (final key in muscleMap.keys) {
        if (m.contains(key) || key.contains(m)) {
          secondaryIds.addAll(muscleMap[key]!);
        }
      }
    }
    secondaryIds.removeAll(primaryIds);

    final primaryHex = _toHex(widget.primaryColor);
    final secondaryHex = _toHex(widget.secondaryColor);

    var result = svg;
    for (final id in primaryIds) {
      result = _replaceIdFill(result, id, primaryHex);
    }
    for (final id in secondaryIds) {
      result = _replaceIdFill(result, id, secondaryHex);
    }
    return result;
  }

  String _replaceIdFill(String svg, String id, String hexColor) {
    // Case 1: id comes before fill
    final p1 = RegExp(
      r'(<(?:path|ellipse|rect)[^>]*\bid="' + RegExp.escape(id) + r'"[^>]*?)fill="[^"]*"',
      dotAll: true,
    );
    if (p1.hasMatch(svg)) {
      return svg.replaceAllMapped(p1, (m) => '${m.group(1)}fill="$hexColor"');
    }
    // Case 2: fill comes before id
    final p2 = RegExp(
      r'(<(?:path|ellipse|rect)[^>]*?)fill="[^"]*"([^>]*\bid="' + RegExp.escape(id) + r'")',
      dotAll: true,
    );
    return svg.replaceAllMapped(p2, (m) => '${m.group(1)}fill="$hexColor"${m.group(2)}');
  }

  String _toHex(Color c) =>
      '#${c.red.toRadixString(16).padLeft(2, '0')}'
      '${c.green.toRadixString(16).padLeft(2, '0')}'
      '${c.blue.toRadixString(16).padLeft(2, '0')}';

  void _flip() {
    if (!widget.allowFlip) return;
    setState(() => _showBack = !_showBack);
    _flipCtrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(MuscleMapWidget old) {
    super.didUpdateWidget(old);
    if (old.primaryMuscles != widget.primaryMuscles ||
        old.secondaryMuscles != widget.secondaryMuscles) {
      _loadSvgs();
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svgData = _showBack ? _backSvg : _frontSvg;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _flip,
          child: AnimatedBuilder(
            animation: _flipCtrl,
            builder: (_, child) {
              final t = _flipCtrl.value;
              // First half: rotate away; second half: rotate back (showing new side)
              final angle = t < 0.5 ? t * 3.14159 : (1 - t) * 3.14159;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: child,
              );
            },
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: svgData == null
                  ? Center(
                      child: CircularProgressIndicator(
                        color: widget.primaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: SvgPicture.string(
                        svgData,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
        ),
        if (widget.allowFlip) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _flip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3A3A6A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync, size: 14, color: widget.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    _showBack ? 'BACK VIEW' : 'FRONT VIEW',
                    style: TextStyle(
                      color: widget.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (widget.primaryMuscles.isNotEmpty) ...[
          const SizedBox(height: 10),
          _MuscleLabels(
            primary: widget.primaryMuscles,
            secondary: widget.secondaryMuscles,
            primaryColor: widget.primaryColor,
          ),
        ],
      ],
    );
  }
}

class _MuscleLabels extends StatelessWidget {
  final List<String> primary;
  final List<String> secondary;
  final Color primaryColor;

  const _MuscleLabels({
    required this.primary,
    required this.secondary,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        ...primary.map((m) => _label(m, primaryColor, filled: true)),
        ...secondary.map((m) => _label(m, primaryColor.withOpacity(0.5), filled: false)),
      ],
    );
  }

  Widget _label(String name, Color color, {required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Text(
        name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
