import 'dart:math' as math;
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../application/scanner_controller.dart';

// ── Scan mode ─────────────────────────────────────────────────────────────────

enum _ScanMode { food, barcode }

// ── Screen ────────────────────────────────────────────────────────────────────

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with TickerProviderStateMixin {
  _ScanMode _mode = _ScanMode.food;
  bool _isScanning = false;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _flashOn = false;

  // Barcode scanner controller
  MobileScannerController? _barcodeCtrl;
  bool _barcodeScanned = false; // prevent duplicate triggers

  // Animations
  late AnimationController _scanLineCtrl;
  late Animation<double> _scanLineAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _rotateCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras.first,
            ResolutionPreset.high, enableAudio: false);
        await _cameraController!.initialize();
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _switchMode(_ScanMode mode) {
    if (_mode == mode) return;
    HapticFeedback.selectionClick();
    setState(() {
      _mode = mode;
      _barcodeScanned = false;
    });
    if (mode == _ScanMode.barcode) {
      _barcodeCtrl ??= MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_barcodeScanned || _isScanning) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() {
      _barcodeScanned = true;
      _isScanning = true;
    });
    HapticFeedback.heavyImpact();

    final result =
        await ref.read(scannerControllerProvider).analyzeBarcodeValue(barcode);

    if (!mounted) return;
    setState(() => _isScanning = false);

    switch (result) {
      case ScanSuccess(:final data):
        _showResultsSheet(context, data);
      case ScanRateLimit():
        _showErrorSnackbar('Product not found. Try again or enter manually.');
      case ScanError(:final message):
        _showErrorSnackbar(message);
    }
    // Allow re-scan after 2s
    Future.delayed(2.seconds, () {
      if (mounted) setState(() => _barcodeScanned = false);
    });
  }

  void _onCapture() async {
    if (!_isCameraInitialized || _cameraController == null || _isScanning)
      return;
    HapticFeedback.heavyImpact();
    setState(() => _isScanning = true);
    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();
      final result = await ref
          .read(scannerControllerProvider)
          .analyzeMeal(bytes, 'image/jpeg');
      if (!mounted) return;
      setState(() => _isScanning = false);
      switch (result) {
        case ScanSuccess(:final data):
          _showResultsSheet(context, data);
        case ScanRateLimit(:final retryAfterSeconds):
          _showErrorSnackbar(
              'API quota reached. Wait $retryAfterSeconds s before retrying.');
        case ScanError(:final message):
          _showErrorSnackbar(message);
      }
    } catch (e) {
      if (mounted) setState(() => _isScanning = false);
      _showErrorSnackbar('Capture failed: $e');
    }
  }

  Future<void> _onGalleryPick() async {
    HapticFeedback.lightImpact();
    try {
      final file = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      setState(() => _isScanning = true);
      final result = await ref
          .read(scannerControllerProvider)
          .analyzeMeal(bytes, 'image/jpeg');
      if (!mounted) return;
      setState(() => _isScanning = false);
      switch (result) {
        case ScanSuccess(:final data):
          _showResultsSheet(context, data);
        case ScanRateLimit(:final retryAfterSeconds):
          _showErrorSnackbar('API quota reached. Wait $retryAfterSeconds s.');
        case ScanError(:final message):
          _showErrorSnackbar(message);
      }
    } catch (e) {
      if (mounted) setState(() => _isScanning = false);
      _showErrorSnackbar('Gallery pick failed: $e');
    }
  }

  void _showManualEntrySheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualEntrySheet(
        onSubmit: (data) {
          Navigator.pop(context);
          _showResultsSheet(context, data);
        },
      ),
    );
  }

  void _showResultsSheet(BuildContext context, Map<String, dynamic> data) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultsBottomSheet(data: data),
    );
  }

  void _showErrorSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _cameraController?.dispose();
    _barcodeCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera / Barcode background ──────────────────────────────────
          if (_mode == _ScanMode.barcode)
            if (_barcodeCtrl != null)
              MobileScanner(
                controller: _barcodeCtrl!,
                onDetect: _onBarcodeDetected,
              )
            else
              const SizedBox.shrink()
          else if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D0D18), Color(0xFF090912)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

          // Vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),
          ),

          // Scanning blur
          if (_isScanning)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child:
                    Container(color: Colors.black.withOpacity(0.2)),
              ),
            ).animate().fadeIn(duration: 300.ms),

          // Top bar
          _buildTopBar(context),

          // AI badge / mode badge
          _buildBadge(context),

          // Reticle (food) or barcode reticle
          _mode == _ScanMode.food ? _buildReticle() : _buildBarcodeReticle(),

          // Mode toggle
          _buildModeToggle(context),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: 400.ms,
              child: _isScanning
                  ? _buildScanningPanel()
                  : _mode == _ScanMode.barcode
                      ? _buildBarcodeHint()
                      : _buildCapturePanel(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 4,
          left: 8,
          right: 8,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.85), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            _TopBarButton(
                icon: PhosphorIconsRegular.arrowLeft,
                onTap: () => context.pop()),
            const Spacer(),
            const Text(
              'AI Food Scanner',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3),
            ),
            const Spacer(),
              _TopBarButton(
                icon: _flashOn
                    ? PhosphorIconsFill.flashlight
                    : PhosphorIconsRegular.flashlight,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _flashOn = !_flashOn);
                  if (_isCameraInitialized && _cameraController != null) {
                    _cameraController!.setFlashMode(
                        _flashOn ? FlashMode.torch : FlashMode.off);
                  }
                  if (_mode == _ScanMode.barcode) {
                    _barcodeCtrl?.toggleTorch();
                  }
                },
              ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
    );
  }

  // ── Mode toggle ──────────────────────────────────────────────────────────────

  Widget _buildModeToggle(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 68,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeChip(
                label: 'Food AI',
                icon: PhosphorIconsFill.sparkle,
                selected: _mode == _ScanMode.food,
                onTap: () => _switchMode(_ScanMode.food),
              ),
              const SizedBox(width: 4),
              _ModeChip(
                label: 'Barcode',
                icon: PhosphorIconsRegular.barcode,
                selected: _mode == _ScanMode.barcode,
                onTap: () => _switchMode(_ScanMode.barcode),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  // ── Badges ───────────────────────────────────────────────────────────────────

  Widget _buildBadge(BuildContext context) {
    final label = _mode == _ScanMode.barcode
        ? (_isScanning ? 'LOOKING UP...' : 'SCAN BARCODE')
        : (_isScanning ? 'ANALYZING...' : 'GEMINI AI VISION');

    return Positioned(
      top: MediaQuery.of(context).padding.top + 118,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Opacity(
            opacity: _pulseAnim.value,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: AppColors.softIndigo.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.softIndigo.withOpacity(0.25),
                      blurRadius: 12)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _mode == _ScanMode.barcode
                        ? PhosphorIconsRegular.barcode
                        : PhosphorIconsFill.sparkle,
                    color: AppColors.softIndigo,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reticles ─────────────────────────────────────────────────────────────────

  Widget _buildReticle() {
    return Center(
      child: SizedBox(
        width: 270,
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.softIndigo
                            .withOpacity(_pulseAnim.value * 0.15),
                        blurRadius: 40,
                        spreadRadius: 10)
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color:
                          Colors.white.withOpacity(_pulseAnim.value * 0.25),
                      width: 1.5),
                ),
              ),
            ),
            CustomPaint(
              size: const Size(260, 260),
              painter: _CornerBracketPainter(
                  color:
                      _isScanning ? AppColors.softIndigo : Colors.white,
                  opacity: _isScanning ? 1.0 : 0.9),
            ),
            if (!_isScanning)
              AnimatedBuilder(
                animation: _scanLineAnim,
                builder: (_, __) {
                  final yOffset = (_scanLineAnim.value * 220) - 110;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 130 + yOffset - 1,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.transparent,
                                AppColors.dynamicMint.withOpacity(0.8),
                                AppColors.dynamicMint,
                                AppColors.dynamicMint.withOpacity(0.8),
                                Colors.transparent,
                              ]),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.dynamicMint
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2)
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            if (_isScanning)
              AnimatedBuilder(
                animation: _rotateCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _rotateCtrl.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _ArcSpinnerPainter(color: AppColors.softIndigo),
                  ),
                ),
              ),
            if (_isScanning)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softIndigo.withOpacity(0.12),
                  border: Border.all(
                      color: AppColors.softIndigo.withOpacity(0.3), width: 1),
                ),
                child: const Icon(PhosphorIconsRegular.aperture,
                    color: AppColors.softIndigo, size: 36),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.9, end: 1.0, duration: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeReticle() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => Container(
          width: 300,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.dynamicMint
                    .withOpacity(0.5 + _pulseAnim.value * 0.4),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color:
                      AppColors.dynamicMint.withOpacity(_pulseAnim.value * 0.2),
                  blurRadius: 20,
                  spreadRadius: 4)
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Horizontal scan line
              Positioned(
                left: 12,
                right: 12,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      AppColors.dynamicMint,
                      Colors.transparent,
                    ]),
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(
                  begin: -1.5,
                  end: 1.5,
                  duration: 1600.ms,
                  curve: Curves.easeInOut),
              // Corner brackets
              CustomPaint(
                size: const Size(300, 160),
                painter: _CornerBracketPainter(
                    color: AppColors.dynamicMint, opacity: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom panels ────────────────────────────────────────────────────────────

  Widget _buildCapturePanel() {
    return Container(
      key: const ValueKey('capture'),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          left: 24,
          right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.92)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Text('Center your meal in the frame',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CameraActionBtn(
                  icon: PhosphorIconsRegular.image,
                  label: 'Gallery',
                  onTap: _onGalleryPick),
              // Shutter
              GestureDetector(
                onTap: _onCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 4)
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [Colors.white, Color(0xFFE0E0E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(
                      begin: 1.0,
                      end: 1.03,
                      duration: 1200.ms,
                      curve: Curves.easeInOut),
              _CameraActionBtn(
                  icon: PhosphorIconsRegular.pencilSimple,
                  label: 'Manual',
                  onTap: _showManualEntrySheet),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildBarcodeHint() {
    return Container(
      key: const ValueKey('barcode'),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.dynamicMint.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(PhosphorIconsRegular.barcode,
                color: AppColors.dynamicMint, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barcode Mode',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                SizedBox(height: 2),
                Text('Point camera at any product barcode',
                    style:
                        TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          _CameraActionBtn(
              icon: PhosphorIconsRegular.pencilSimple,
              label: 'Manual',
              onTap: _showManualEntrySheet),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildScanningPanel() {
    return Container(
      key: const ValueKey('scanning'),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softIndigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(PhosphorIconsFill.sparkle,
                          color: AppColors.softIndigo, size: 16),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.85, end: 1.0, duration: 800.ms),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mode == _ScanMode.barcode
                                ? 'Looking up product...'
                                : 'AI is analyzing...',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Text(
                            _mode == _ScanMode.barcode
                                ? 'Searching Open Food Facts'
                                : 'Identifying ingredients & macros',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: AppColors.softIndigo,
                              shape: BoxShape.circle),
                        )
                            .animate(
                              delay: Duration(milliseconds: i * 180),
                              onPlay: (c) => c.repeat(reverse: true),
                            )
                            .scaleXY(begin: 0.4, end: 1.0, duration: 500.ms),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AnimatedProgressBar(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ScanStep(label: 'Detect', done: true),
                    _ScanStep(label: 'Identify', active: true),
                    _ScanStep(label: 'Calculate'),
                    _ScanStep(label: 'Log'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isScanning = false;
                        _barcodeScanned = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.white.withOpacity(0.15)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white.withOpacity(0.04),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}

// ── Mode chip ──────────────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.softIndigo
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : Colors.white54),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.white54)),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CameraActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CameraActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4));
    _anim = Tween<double>(begin: 0, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(3)),
        ),
        FractionallySizedBox(
          widthFactor: _anim.value,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.softIndigo, AppColors.dynamicMint]),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                    color: AppColors.softIndigo.withOpacity(0.5),
                    blurRadius: 6)
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _ScanStep extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  const _ScanStep({required this.label, this.done = false, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.dynamicMint
        : active
            ? AppColors.softIndigo
            : Colors.white24;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 1.5),
          ),
          child: done
              ? Icon(Icons.check, color: color, size: 14)
              : active
                  ? Center(
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: color)))
                  : null,
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Custom Painters ───────────────────────────────────────────────────────────

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const _CornerBracketPainter({required this.color, this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    const r = 16.0;
    canvas.drawPath(
        Path()
          ..moveTo(r, 0)
          ..lineTo(len, 0)
          ..moveTo(0, r)
          ..lineTo(0, len),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(size.width - len, 0)
          ..lineTo(size.width - r, 0)
          ..moveTo(size.width, r)
          ..lineTo(size.width, len),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(0, size.height - len)
          ..lineTo(0, size.height - r)
          ..moveTo(r, size.height)
          ..lineTo(len, size.height),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(size.width, size.height - len)
          ..lineTo(size.width, size.height - r)
          ..moveTo(size.width - len, size.height)
          ..lineTo(size.width - r, size.height),
        paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter old) =>
      old.color != color || old.opacity != opacity;
}

class _ArcSpinnerPainter extends CustomPainter {
  final Color color;
  const _ArcSpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0,
        math.pi * 1.2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Manual Entry Sheet ────────────────────────────────────────────────────────

class _ManualEntrySheet extends ConsumerStatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;
  const _ManualEntrySheet({required this.onSubmit});

  @override
  ConsumerState<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends ConsumerState<_ManualEntrySheet> {
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  String _mealType = 'snack';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name =
        _nameCtrl.text.trim().isEmpty ? 'Manual Entry' : _nameCtrl.text.trim();
    final cal = int.tryParse(_calCtrl.text) ?? 0;
    final pro = int.tryParse(_proCtrl.text) ?? 0;
    final carb = int.tryParse(_carbCtrl.text) ?? 0;
    final fat = int.tryParse(_fatCtrl.text) ?? 0;
    ref.read(scannerControllerProvider).saveMealToLog(
        calories: cal,
        protein: pro,
        carbs: carb,
        fat: fat,
        name: name,
        mealType: _mealType,
        source: 'manual');
    widget.onSubmit({
      'name': name,
      'calories': cal,
      'protein': pro,
      'carbs': carb,
      'fat': fat
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121218) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.softIndigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(PhosphorIconsFill.pencilSimple,
                      color: AppColors.softIndigo, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Manual Entry',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3)),
              ]),
              const SizedBox(height: 20),
              _ManualTextField(
                  ctrl: _nameCtrl,
                  label: 'Food Name',
                  hint: 'e.g. Chicken Rice Bowl',
                  isDark: isDark),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _ManualTextField(
                        ctrl: _calCtrl,
                        label: 'Calories (kcal)',
                        hint: '0',
                        isDark: isDark,
                        numeric: true)),
                const SizedBox(width: 10),
                Expanded(
                    child: _ManualTextField(
                        ctrl: _proCtrl,
                        label: 'Protein (g)',
                        hint: '0',
                        isDark: isDark,
                        numeric: true)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _ManualTextField(
                        ctrl: _carbCtrl,
                        label: 'Carbs (g)',
                        hint: '0',
                        isDark: isDark,
                        numeric: true)),
                const SizedBox(width: 10),
                Expanded(
                    child: _ManualTextField(
                        ctrl: _fatCtrl,
                        label: 'Fat (g)',
                        hint: '0',
                        isDark: isDark,
                        numeric: true)),
              ]),
              const SizedBox(height: 16),
              Text('Meal Type',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5))),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final (val, label) in [
                    ('breakfast', 'Breakfast'),
                    ('lunch', 'Lunch'),
                    ('dinner', 'Dinner'),
                    ('snack', 'Snack'),
                  ]) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mealType = val),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _mealType == val
                                ? AppColors.softIndigo
                                : AppColors.softIndigo.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _mealType == val
                                      ? Colors.white
                                      : AppColors.softIndigo)),
                        ),
                      ),
                    ),
                    if (val != 'snack') const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softIndigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsFill.plus, size: 18),
                      SizedBox(width: 8),
                      Text('Save to Log',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool isDark;
  final bool numeric;
  const _ManualTextField(
      {required this.ctrl,
      required this.label,
      required this.hint,
      required this.isDark,
      this.numeric = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType:
              numeric ? TextInputType.number : TextInputType.text,
          style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.withOpacity(0.4)),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.softIndigo, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

// ── Results Bottom Sheet ──────────────────────────────────────────────────────
// Handles: single food, multi-food (items array), barcode results
// Features: portion slider, item toggles, confidence chip

class _ResultsBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const _ResultsBottomSheet({required this.data});

  @override
  ConsumerState<_ResultsBottomSheet> createState() =>
      _ResultsBottomSheetState();
}

class _ResultsBottomSheetState extends ConsumerState<_ResultsBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _saved = false;
  String _mealType = 'snack';
  double _portionMultiplier = 1.0;

  // Multi-food: track which items are selected
  late List<bool> _itemSelected;
  bool get _isMulti =>
      widget.data['items'] != null && widget.data['items'] is List;

  List<Map<String, dynamic>> get _items {
    if (!_isMulti) return [];
    return List<Map<String, dynamic>>.from(
        (widget.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
  }

  // Effective totals (after item toggles + portion multiplier)
  int get _effectiveCal {
    if (_isMulti) {
      final base = _items
          .asMap()
          .entries
          .where((e) => _itemSelected[e.key])
          .fold(0, (s, e) => s + ((e.value['calories'] as num?)?.toInt() ?? 0));
      return (base * _portionMultiplier).round();
    }
    return ((widget.data['calories'] as num?)?.toDouble() ?? 0) *
        _portionMultiplier ~/
        1;
  }

  int get _effectiveProtein {
    if (_isMulti) {
      final base = _items
          .asMap()
          .entries
          .where((e) => _itemSelected[e.key])
          .fold(0, (s, e) => s + ((e.value['protein'] as num?)?.toInt() ?? 0));
      return (base * _portionMultiplier).round();
    }
    return ((widget.data['protein'] as num?)?.toDouble() ?? 0) *
        _portionMultiplier ~/
        1;
  }

  int get _effectiveCarbs {
    if (_isMulti) {
      final base = _items
          .asMap()
          .entries
          .where((e) => _itemSelected[e.key])
          .fold(0, (s, e) => s + ((e.value['carbs'] as num?)?.toInt() ?? 0));
      return (base * _portionMultiplier).round();
    }
    return ((widget.data['carbs'] as num?)?.toDouble() ?? 0) *
        _portionMultiplier ~/
        1;
  }

  int get _effectiveFat {
    if (_isMulti) {
      final base = _items
          .asMap()
          .entries
          .where((e) => _itemSelected[e.key])
          .fold(0, (s, e) => s + ((e.value['fat'] as num?)?.toInt() ?? 0));
      return (base * _portionMultiplier).round();
    }
    return ((widget.data['fat'] as num?)?.toDouble() ?? 0) *
        _portionMultiplier ~/
        1;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 600.ms)..forward();
    _itemSelected = List.filled(_items.length, true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _portionLabel {
    if (_portionMultiplier <= 0.5) return '½ portion';
    if (_portionMultiplier <= 0.75) return '¾ portion';
    if (_portionMultiplier <= 1.0) return '1 portion';
    if (_portionMultiplier <= 1.25) return '1¼ portion';
    if (_portionMultiplier <= 1.5) return '1½ portion';
    if (_portionMultiplier <= 1.75) return '1¾ portion';
    return '2× portion';
  }

  Color get _confidenceColor {
    final c = (widget.data['confidence'] as String?)?.toLowerCase() ?? '';
    if (c == 'high') return AppColors.dynamicMint;
    if (c == 'moderate') return AppColors.warning;
    return AppColors.danger;
  }

  String get _confidenceLabel {
    final c = (widget.data['confidence'] as String?)?.toLowerCase() ?? '';
    if (c == 'high') return 'High confidence';
    if (c == 'moderate') return 'Moderate confidence';
    if (c.isNotEmpty) return 'Uncertain';
    return '';
  }

  void _save() async {
    HapticFeedback.heavyImpact();
    final controller = ref.read(scannerControllerProvider);

    if (_isMulti) {
      // Save each selected item separately
      for (var i = 0; i < _items.length; i++) {
        if (!_itemSelected[i]) continue;
        final item = _items[i];
        await controller.saveMealToLog(
          calories: (item['calories'] as num?)?.toInt() ?? 0,
          protein: (item['protein'] as num?)?.toInt() ?? 0,
          carbs: (item['carbs'] as num?)?.toInt() ?? 0,
          fat: (item['fat'] as num?)?.toInt() ?? 0,
          name: item['name']?.toString() ?? 'Food Item',
          mealType: _mealType,
          source: 'scan',
          portionMultiplier: _portionMultiplier,
        );
      }
    } else {
      await controller.saveMealToLog(
        calories: (widget.data['calories'] as num?)?.toInt() ?? 0,
        protein: (widget.data['protein'] as num?)?.toInt() ?? 0,
        carbs: (widget.data['carbs'] as num?)?.toInt() ?? 0,
        fat: (widget.data['fat'] as num?)?.toInt() ?? 0,
        name: widget.data['name']?.toString() ?? 'Scanned Meal',
        mealType: _mealType,
        source: widget.data['source']?.toString() ?? 'scan',
        barcode: widget.data['barcode']?.toString(),
        portionMultiplier: _portionMultiplier,
      );
    }

    setState(() => _saved = true);
    await Future.delayed(1200.ms);
    if (mounted) {
      context.pop();
      context.pop();
    }
  }

  double _calcPct(int value, double max) => (value / max).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBarcode = widget.data['source'] == 'barcode';
    final mealName = widget.data['name']?.toString() ?? 'Detected Meal';
    final portionHint =
        widget.data['portion']?.toString();
    final confidence = _confidenceLabel;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121218) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
          border:
              Border.all(color: Colors.white.withOpacity(isDark ? 0.08 : 0)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20),
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isBarcode
                            ? [
                                AppColors.dynamicMint,
                                const Color(0xFF00C78C)
                              ]
                            : [
                                AppColors.softIndigo,
                                const Color(0xFF9B59B6)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: (isBarcode
                                    ? AppColors.dynamicMint
                                    : AppColors.softIndigo)
                                .withOpacity(0.4),
                            blurRadius: 12)
                      ],
                    ),
                    child: Icon(
                      isBarcode
                          ? PhosphorIconsRegular.barcode
                          : PhosphorIconsFill.sparkle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBarcode ? 'BARCODE RESULT' : 'GEMINI ANALYSIS',
                          style: TextStyle(
                              color: isBarcode
                                  ? AppColors.dynamicMint
                                  : AppColors.softIndigo,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                        ),
                        Text(
                          mealName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Confidence chip
                  if (confidence.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _confidenceColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _confidenceColor.withOpacity(0.3)),
                      ),
                      child: Text(confidence,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _confidenceColor)),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // ── Calorie hero ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1530), const Color(0xFF130E20)]
                        : [
                            const Color(0xFFF0EEFF),
                            const Color(0xFFE8E0FF)
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.softIndigo.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CALORIES',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppColors.softIndigo
                                      .withOpacity(0.7))),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: _effectiveCal),
                            duration: 400.ms,
                            builder: (_, v, __) => RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: '$v',
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.softIndigo,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' kcal',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.softIndigo,
                                      fontWeight: FontWeight.w400),
                                ),
                              ]),
                            ),
                          ),
                          if (portionHint != null)
                            Text(portionHint,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38)),
                        ],
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                          begin: 0,
                          end: (_effectiveCal / 2000).clamp(0.0, 1.0)),
                      duration: 1000.ms,
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: v,
                              strokeWidth: 7,
                              backgroundColor:
                                  AppColors.softIndigo.withOpacity(0.15),
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.softIndigo),
                              strokeCap: StrokeCap.round,
                            ),
                            Text('${(v * 100).toInt()}%',
                                style: const TextStyle(
                                    color: AppColors.softIndigo,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            // ── Multi-food item toggles ────────────────────────────────────
            if (_isMulti) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Text('Food Items Detected',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ..._items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final selected = _itemSelected[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _itemSelected[i] = !_itemSelected[i]);
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.softIndigo.withOpacity(
                                isDark ? 0.15 : 0.08)
                            : (isDark
                                ? Colors.white.withOpacity(0.03)
                                : Colors.grey.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.softIndigo.withOpacity(0.4)
                              : Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: 200.ms,
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? AppColors.softIndigo
                                  : Colors.transparent,
                              border: Border.all(
                                color: selected
                                    ? AppColors.softIndigo
                                    : Colors.grey.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(Icons.check,
                                    size: 13, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name']?.toString() ?? 'Item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? (isDark
                                            ? Colors.white
                                            : AppColors.lightTextPrimary)
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['protein'] ?? 0}g P  •  ${item['carbs'] ?? 0}g C  •  ${item['fat'] ?? 0}g F',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? (isDark
                                            ? Colors.white54
                                            : Colors.black45)
                                        : Colors.grey.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item['calories'] ?? 0} kcal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? AppColors.softIndigo
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],

            // ── Macros ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Macronutrients',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  _MacroBar(
                      label: 'Protein',
                      grams: _effectiveProtein,
                      color: AppColors.dynamicMint,
                      pct: _calcPct(_effectiveProtein, 150),
                      delay: 200),
                  const SizedBox(height: 12),
                  _MacroBar(
                      label: 'Carbs',
                      grams: _effectiveCarbs,
                      color: AppColors.warning,
                      pct: _calcPct(_effectiveCarbs, 300),
                      delay: 280),
                  const SizedBox(height: 12),
                  _MacroBar(
                      label: 'Fats',
                      grams: _effectiveFat,
                      color: AppColors.danger,
                      pct: _calcPct(_effectiveFat, 80),
                      delay: 360),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Portion size slider ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Portion Size',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.softIndigo.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_portionLabel,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.softIndigo)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.softIndigo,
                      inactiveTrackColor:
                          AppColors.softIndigo.withOpacity(0.15),
                      thumbColor: AppColors.softIndigo,
                      overlayColor: AppColors.softIndigo.withOpacity(0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _portionMultiplier,
                      min: 0.25,
                      max: 2.0,
                      divisions: 7,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _portionMultiplier = v);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('¼',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.black38)),
                      Text('½',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.black38)),
                      Text('1×',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softIndigo)),
                      Text('1.5×',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.black38)),
                      Text('2×',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.black38)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Meal type selector ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meal Type',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final (val, label) in [
                        ('breakfast', 'Breakfast'),
                        ('lunch', 'Lunch'),
                        ('dinner', 'Dinner'),
                        ('snack', 'Snack'),
                      ]) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _mealType = val),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _mealType == val
                                    ? AppColors.softIndigo
                                    : AppColors.softIndigo
                                        .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _mealType == val
                                          ? Colors.white
                                          : AppColors.softIndigo)),
                            ),
                          ),
                        ),
                        if (val != 'snack') const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Action buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _saved
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.dynamicMint.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                AppColors.dynamicMint.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIconsBold.check,
                              color: AppColors.dynamicMint, size: 20),
                          SizedBox(width: 8),
                          Text('Saved to Log!',
                              style: TextStyle(
                                  color: AppColors.dynamicMint,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ).animate().scale(
                      duration: 400.ms, curve: Curves.easeOutBack)
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              side: BorderSide(
                                  color: Colors.grey.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Retake',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              backgroundColor: AppColors.softIndigo,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(PhosphorIconsFill.plus, size: 18),
                                SizedBox(width: 8),
                                Text('Save to Log',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Macro bar ──────────────────────────────────────────────────────────────────

class _MacroBar extends StatelessWidget {
  final String label;
  final int grams;
  final Color color;
  final double pct;
  final int delay;

  const _MacroBar({
    required this.label,
    required this.grams,
    required this.color,
    required this.pct,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? Colors.white70 : AppColors.lightTextPrimary)),
            Text('${grams}g',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: pct),
          duration: Duration(milliseconds: 800 + delay),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => Stack(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [color.withOpacity(0.7), color]),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.3), blurRadius: 4)
                  ],
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
