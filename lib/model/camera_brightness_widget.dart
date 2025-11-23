import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:boatmotion/model/aruco_detector.dart';
import 'package:boatmotion/model/laser.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv_dart.dart' as dartcv;
import 'package:sensors_plus/sensors_plus.dart';

class CameraBrightnessWidget extends StatefulWidget {
  const CameraBrightnessWidget({super.key});

  @override
  State<CameraBrightnessWidget> createState() => _CameraBrightnessWidgetState();
}

class _CameraBrightnessWidgetState extends State<CameraBrightnessWidget> {
  CameraController? _controller;
  // Добавляем переменные для преобразования координат
  double _scaleX = 1.0;
  double _scaleY = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _correctionX = 0.0; // Добавляем коррекцию
  Size? _frameSize;
  Size? _screenSize;
  final GlobalKey _previewKey = GlobalKey();
  Offset? _previewCenter;
  Size? _actualPreviewSize;

  int minXLaserZone = 10;
  int maxXLaserZone = 250;
  int minYLaserZone = 10;
  int maxYLaserZone = 250;

  List<CameraDescription>? _cameras;
  double _brightness = 0.0;
  bool _isInitialized = false;
  bool _isProcessing = false;
  DateTime _lastProcessTime = DateTime.now();
  double _tiltAngle = 0.0;
  double _rollAngle = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isCalibrating = false;
  double _calibrationOffset = 0.0;
  List<dartcv.Point2f> _detectedCenters = [];
  List<dartcv.Point2f> _detectedLaserCenters = [];
  late ArucoDetectorService _arucoService;

  @override
  void initState() {
    super.initState();
    _arucoService = ArucoDetectorService();
    _initializeCamera();
    _startAccelerometer();
    // _calculatePreviewCenter();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _controller?.dispose();
    _arucoService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        throw Exception('No cameras found');
      }

      // Выбираем заднюю камеру
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      // Разрешаем автоматическую ориентацию
      // await _controller!.lockCaptureOrientation(DeviceOrientation.landscapeRight);

      // Получаем размеры preview ДО начала потока
      final previewSize = _controller!.value.previewSize;
      print(
        'Preview размер после инициализации: ${previewSize!.width} x ${previewSize.height}',
      );

      setState(() {
        _isInitialized = true;
      });

      _controller!.startImageStream(_processCameraImage);
      // _controller.
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      if (!mounted) return;

      // Рассчитываем углы наклона по данным акселерометра
      final double x = event.x;
      final double y = event.y;
      final double z = event.z;

      // Угол крена (roll) - наклон влево/вправо
      _rollAngle = _calculateRollAngle(x, y, z);

      // Угол тангажа (pitch) - наклон вперед/назад
      _tiltAngle = _calculatePitchAngle(x, y, z);

      // Корректируем с учетом калибровки
      final correctedRoll = _rollAngle - _calibrationOffset;

      if (mounted) {
        setState(() {
          _rollAngle = correctedRoll;
        });
      }
    });
  }

  // void _calculatePreviewCenter() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final renderBox =
  //         _previewKey.currentContext?.findRenderObject() as RenderBox?;
  //     if (renderBox != null) {
  //       final previewSize = renderBox.size;
  //       final previewPosition = renderBox.localToGlobal(Offset.zero);

  //       _previewCenter = Offset(
  //         previewPosition.dx + previewSize.width / 2,
  //         previewPosition.dy + previewSize.height / 2,
  //       );

  //       print('Центр preview: $_previewCenter');
  //       print('Размер preview: $previewSize');
  //       print('Позиция preview: $previewPosition');
  //     }
  //   });
  // }

  double _calculateRollAngle(double x, double y, double z) {
    // Расчет угла крена (наклон влево/вправо)
    return atan2(y, sqrt(x * x + z * z)) * (180 / pi);
  }

  double _calculatePitchAngle(double x, double y, double z) {
    // Расчет угла тангажа (наклон вперед/назад)
    return atan2(-x, sqrt(y * y + z * z)) * (180 / pi);
  }

  // void _calibrateHorizon() {
  //   setState(() {
  //     _isCalibrating = true;
  //   });

  //   // Собираем несколько измерений для точной калибровки
  //   final measurements = <double>[];
  //   final stopwatch = Stopwatch()..start();

  //   final calibrationSubscription = accelerometerEvents.listen((event) {
  //     if (stopwatch.elapsedMilliseconds > 1000) {
  //       calibrationSubscription.cancel();
  //       _finalizeCalibration(measurements);
  //       return;
  //     }

  //     final roll = _calculateRollAngle(event.x, event.y, event.z);
  //     measurements.add(roll);
  //   });
  // }

  void _calibrateHorizon() {
    setState(() {
      _isCalibrating = true;
    });

    final measurements = <double>[];

    final calibrationSubscription = accelerometerEvents.listen((event) {
      final roll = _calculateRollAngle(event.x, event.y, event.z);
      measurements.add(roll);
    });

    // Останавливаем через 1 секунду
    Timer(const Duration(seconds: 1), () {
      calibrationSubscription.cancel();
      _finalizeCalibration(measurements);
    });
  }

  void _finalizeCalibration(List<double> measurements) {
    if (measurements.isEmpty) return;

    // Берем медиану для устранения выбросов
    measurements.sort();
    final median = measurements[measurements.length ~/ 2];

    setState(() {
      _calibrationOffset = median;
      _isCalibrating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Горизонт откалиброван. Смещение: ${_calibrationOffset.toStringAsFixed(1)}°',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _processCameraImage(CameraImage image) async {
    final now = DateTime.now();
    // image
    if (now.difference(_lastProcessTime).inMilliseconds < 100 ||
        _isProcessing) {
      return;
    }

    _isProcessing = true;
    _lastProcessTime = now;

    try {
      final brightness = await _calculateBrightness(image);
      // final centers = await compute(_processArucoInIsolate, image);

      final centersLaserData = await compute(
        _processLaserInIsolate,
        LaserProcessingData(
          image: image,
          minXLaserZone: minXLaserZone,
          maxXLaserZone: maxXLaserZone,
          minYLaserZone: minYLaserZone,
          maxYLaserZone: maxYLaserZone,
        ),
      );
      final centersLaser =
          centersLaserData
              .map((data) => dartcv.Point2f(data[0], data[1]))
              .toList();

      final centersData = await compute(_processArucoInIsolate, image);
      // Конвертируем обратно в Point2f
      final centers =
          centersData.map((data) => dartcv.Point2f(data[0], data[1])).toList();

      if (mounted) {
        setState(() {
          _brightness = brightness;
          _detectedCenters = centers;
          _detectedLaserCenters = centersLaser;
          print("$_detectedCenters");
        });
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  // Для использования в isolate
  // static List<dartcv.Point2f> _processArucoInIsolate(CameraImage image) {
  // Вместо List<Point2f> возвращаем List<List<double>>
  static List<List<double>> _processArucoInIsolate(CameraImage image) {
    final service = ArucoDetectorService();
    try {
      // return service.processFrame(image);
      final centers = service.processFrame(image);
      // Конвертируем Point2f в List<double>
      return centers.map((point) => [point.x, point.y]).toList();
    } finally {
      service.dispose();
    }
  }

  // Для использования в isolate
  static List<List<double>> _processLaserInIsolate(LaserProcessingData data) {
    final service = LaserDetectorService();
    try {
      // return service.processFrame(image);

      final centers = service.processLaserFrame(data);
      // Конвертируем Point2f в List<double>
      return centers.map((point) => [point.x, point.y]).toList();
    } finally {
      service.dispose();
    }
  }

  Future<double> _calculateBrightness(CameraImage image) async {
    return await compute(_isolatedBrightnessCalculation, image);
  }

  static double _isolatedBrightnessCalculation(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final startX = (width * 0.25).round();
    final startY = (height * 0.25).round();
    final endX = (width * 0.75).round();
    final endY = (height * 0.75).round();

    double totalBrightness = 0;
    int pixelCount = 0;

    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        final yPlane = image.planes[0];
        final yBytes = yPlane.bytes;
        final yRowStride = yPlane.bytesPerRow;

        for (int y = startY; y < endY; y += 2) {
          for (int x = startX; x < endX; x += 2) {
            final yIndex = (y * yRowStride) + x;
            if (yIndex < yBytes.length) {
              final luminance = yBytes[yIndex] & 0xFF;
              totalBrightness += luminance / 255.0;
              pixelCount++;
            }
          }
        }
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        final bytes = image.planes[0].bytes;
        final bytesPerPixel = 4;
        final rowStride = image.planes[0].bytesPerRow;

        for (int y = startY; y < endY; y += 2) {
          for (int x = startX; x < endX; x += 2) {
            final pixelIndex = (y * rowStride) + (x * bytesPerPixel);
            if (pixelIndex + 2 < bytes.length) {
              final b = bytes[pixelIndex] & 0xFF;
              final g = bytes[pixelIndex + 1] & 0xFF;
              final r = bytes[pixelIndex + 2] & 0xFF;

              final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
              totalBrightness += luminance;
              pixelCount++;
            }
          }
        }
      }
    } catch (e) {
      print('Error in brightness calculation: $e');
    }

    return pixelCount > 0 ? totalBrightness / pixelCount : 0.0;
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Загрузка камеры... buildCameraPreview',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    final previewSize = _controller!.value.previewSize!;

    // return Container(
    //   width: double.infinity,
    //   height: double.infinity,
    //   color: Colors.black,
    //   child: Stack(
    //     children: [
    //       // Основное изображение камеры
    //       // Center(
    //       //   child: AspectRatio(
    //       //     // aspectRatio: _controller!.value.previewSize!.height / _controller!.value.previewSize!.width,
    //       //     aspectRatio: _controller!.value.previewSize!.width / _controller!.value.previewSize!.height,
    //       //     child: CameraPreview(_controller!),
    //       //   ),
    //       // ),
    //       // Плюсы: Сохраняет все изображение без искажений
    //       // Минусы: Черные поля по бокам
    //       // FittedBox(fit: BoxFit.contain, child: CameraPreview(_controller!)),
    //       AspectRatio(
    //         aspectRatio: previewSize.width / previewSize.height,
    //         child: FittedBox(
    //           fit: BoxFit.contain, // или BoxFit.contain   BoxFit.cover
    //           child: SizedBox(
    //             width: previewSize.width.toDouble(),
    //             height: previewSize.height.toDouble(),
    //             child: CameraPreview(_controller!),
    //           ),
    //         ),
    //       ),
    //       _buildMarkerOverlay(),
    //       // Индикатор горизонта
    //       Positioned(
    //         top: 20,
    //         left: 0,
    //         right: 0,
    //         child: _buildHorizonIndicator(),
    //       ),

    //       // Уровень с индикацией угла
    //       Positioned(
    //         bottom: 20,
    //         left: 0,
    //         right: 0,
    //         child: _buildLevelIndicator(),
    //       ),
    //     ],
    //   ),
    // );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Сохраняем размер экрана
        _screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        // _calculatePreviewCenter();
        // Рассчитываем масштаб и смещение для преобразования координат
        _calculateTransformation(previewSize, _screenSize!);

        // Рассчитываем фактический размер preview после FittedBox
        _actualPreviewSize = _calculateActualPreviewSize(
          previewSize,
          _screenSize!,
        );
        _previewCenter = Offset(
          _screenSize!.width / 2,
          _screenSize!.height / 2,
        );

        // print('Фактический размер preview: $_actualPreviewSize');
        // print('Центр preview: $_previewCenter');

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: previewSize.width / previewSize.height,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: previewSize.width.toDouble(),
                    height: previewSize.height.toDouble(),
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
              _buildMarkerOverlay(),
              // _buildHorizonIndicator(),
              // _buildLevelIndicator(),
            ],
          ),
        );
      },
    );
  }

  Size _calculateActualPreviewSize(Size frameSize, Size containerSize) {
    final frameRatio = frameSize.width / frameSize.height;
    final containerRatio = containerSize.width / containerSize.height;

    if (frameRatio > containerRatio) {
      // Preview шире контейнера - ограничение по ширине
      final width = containerSize.width;
      final height = width / frameRatio;
      return Size(width, height);
    } else {
      // Preview уже контейнера - ограничение по высоте
      final height = containerSize.height;
      final width = height * frameRatio;
      return Size(width, height);
    }
  }

  void _calculateTransformation(Size frameSize, Size screenSize) {
    _frameSize = frameSize;

    final frameRatio = frameSize.width / frameSize.height;
    final screenRatio = screenSize.width / screenSize.height;

    if (frameRatio > screenRatio) {
      // Preview шире экрана - черные поля сверху и снизу
      _scaleX = screenSize.width / frameSize.width;
      _scaleY = _scaleX;
      _offsetX = 0;
      _offsetY = (screenSize.height - (frameSize.height * _scaleY)) / 2;

      // Для этого случая коррекция не нужна
      _correctionX = 0;
    } else {
      // Preview уже экрана - черные поля по бокам
      _scaleY = screenSize.height / frameSize.height;
      _scaleX = _scaleY;
      _offsetX = (screenSize.width - (frameSize.width * _scaleX)) / 2;
      _offsetY = 0;

      // Эмпирическая коррекция для смещения вправо
      _offsetX = (_previewCenter?.dx ?? 0) - 640.0 / 2.0 - 36;
      _correctionX = _offsetX; // или другое значение
    }

    // print('Масштаб: X=$_scaleX, Y=$_scaleY');
    // print('Смещение: X=$_offsetX, Y=$_offsetY');
  }

  // Преобразование координат из системы кадра в систему экрана
  dartcv.Point2f _transformCoordinates(dartcv.Point2f framePoint) {
    return dartcv.Point2f(
      framePoint.x * _scaleX + _offsetX,
      framePoint.y * _scaleY + _offsetY,
    );
  }

  // void _calculateTransformation(Size frameSize, Size screenSize) {
  //   _frameSize = frameSize;

  //   final frameRatio = frameSize.width / frameSize.height;
  //   final screenRatio = screenSize.width / screenSize.height;

  //   if (frameRatio > screenRatio) {
  //     // Preview шире экрана - черные поля сверху и снизу
  //     _scaleX = screenSize.width / frameSize.width;
  //     _scaleY = _scaleX;
  //     _offsetX = 0;
  //     _offsetY = (screenSize.height - (frameSize.height * _scaleY)) / 2;

  //     // Для этого случая коррекция не нужна
  //     _correctionX = 0;
  //   } else {
  //     // Preview уже экрана - черные поля по бокам
  //     _scaleY = screenSize.height / frameSize.height;
  //     _scaleX = _scaleY;
  //     _offsetX = (screenSize.width - (frameSize.width * _scaleX)) / 2;
  //     _offsetY = 0;

  //     // Эмпирическая коррекция для смещения вправо
  //     _correctionX = _offsetX; // или другое значение
  //   }

  //   print('Масштаб: X=$_scaleX, Y=$_scaleY');
  //   print('Смещение: X=$_offsetX, Y=$_offsetY');
  //   print('Коррекция X: $_correctionX');
  // }

  Widget _buildHorizonIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Центральная линия горизонта
          Center(child: Container(height: 2, color: Colors.green)),

          // Подвижный индикатор наклона
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: 50 + (_rollAngle * 2), // Масштабируем для лучшей видимости
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: _getTiltColor()),
          ),

          // Текст с углом наклона
          Center(
            child:
            // Text("previewSize!.height: ${_controller!.value.previewSize!.height} previewSize!.width: ${_controller!.value.previewSize!.width} "),
            Text(
              '${_rollAngle.abs().toStringAsFixed(1)}°  previewSize!.height: ${_controller!.value.previewSize!.height} previewSize!.width: ${_controller!.value.previewSize!.width}  ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator() {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 40),
      // padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'КРЕН',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              Text(
                '${_rollAngle.abs().toStringAsFixed(1)}°',
                style: TextStyle(
                  color: _getTiltColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getTiltDirection(_rollAngle),
                style: TextStyle(color: _getTiltColor(), fontSize: 12),
              ),
            ],
          ),
          // Column(
          //   children: [
          //     Text(
          //       'ТАНГАЖ',
          //       style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          //     ),
          //     Text(
          //       '${_tiltAngle.abs().toStringAsFixed(1)}°',
          //       style: TextStyle(
          //         color: _getPitchColor(),
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     Text(
          //       _getPitchDirection(_tiltAngle),
          //       style: TextStyle(color: _getPitchColor(), fontSize: 12),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Color _getTiltColor() {
    final absAngle = _rollAngle.abs();
    if (absAngle < 1.0) return Colors.green;
    if (absAngle < 3.0) return Colors.yellow;
    return Colors.red;
  }

  Color _getPitchColor() {
    final absAngle = _tiltAngle.abs();
    if (absAngle < 1.0) return Colors.green;
    if (absAngle < 3.0) return Colors.yellow;
    return Colors.red;
  }

  String _getTiltDirection(double angle) {
    if (angle.abs() < 0.5) return 'ГОРИЗОНТ';
    return angle > 0 ? '_ВПРАВО_' : '_ВЛЕВО__';
  }

  String _getPitchDirection(double angle) {
    if (angle.abs() < 0.5) return 'ПРЯМО';
    return angle > 0 ? 'ВВЕРХ' : 'ВНИЗ';
  }

  String _getBrightnessLevel(double brightness) {
    if (brightness < 0.2) return 'Очень темно';
    if (brightness < 0.4) return 'Темно';
    if (brightness < 0.6) return 'Нормально';
    if (brightness < 0.8) return 'Светло';
    return 'Очень светло';
  }

  Color _getBrightnessColor(double brightness) {
    if (brightness < 0.2) return Colors.red;
    if (brightness < 0.4) return Colors.orange;
    if (brightness < 0.6) return Colors.yellow;
    if (brightness < 0.8) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitialized ? _buildLandscapeLayout() : _buildLoadingScreen(),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return
    // Row(
    Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildCameraPreview(),

                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.0, //0.25,
                    top: MediaQuery.of(context).size.height * 0.0, //0.25,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0, //0.5,
                      height: MediaQuery.of(context).size.height * 1.0, //0.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.withOpacity(0.7),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              border: Border(left: BorderSide(color: Colors.grey.shade800)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Индикация ориентации
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: Colors.blue.shade900.withOpacity(0.3),
                //     borderRadius: BorderRadius.circular(10),
                //     border: Border.all(color: Colors.blue.shade700),
                //   ),
                //   child: Column(
                //     children: [
                //       Icon(Icons.straighten, color: _getTiltColor(), size: 32),
                //       const SizedBox(height: 8),
                //       Text(
                //         'Горизонт',
                //         style: TextStyle(
                //           color: Colors.grey.shade300,
                //           fontSize: 14,
                //         ),
                //       ),
                //       Text(
                //         '${_rollAngle.abs().toStringAsFixed(1)}°',
                //         style: TextStyle(
                //           color: _getTiltColor(),
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // const SizedBox(height: 16),

                // Яркость
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getBrightnessColor(_brightness).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getBrightnessColor(_brightness),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${(_brightness * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getBrightnessColor(_brightness),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getBrightnessLevel(_brightness),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getBrightnessColor(_brightness),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildLevelIndicator(),

                // Progress bar яркости
                // Column(
                //   children: [
                //     Text(
                //       'Яркость',
                //       style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                //     ),
                //     const SizedBox(height: 8),
                //     LinearProgressIndicator(
                //       value: _brightness,
                //       backgroundColor: Colors.grey.shade800,
                //       valueColor: AlwaysStoppedAnimation<Color>(
                //         _getBrightnessColor(_brightness),
                //       ),
                //       minHeight: 8,
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //   ],
                // ),

                // const SizedBox(height: 20),

                // Кнопка калибровки
                // ElevatedButton.icon(
                //   onPressed: _isCalibrating ? null : _calibrateHorizon,
                //   icon:
                //       _isCalibrating
                //           ? const SizedBox(
                //             width: 16,
                //             height: 16,
                //             child: CircularProgressIndicator(strokeWidth: 2),
                //           )
                //           : const Icon(Icons.calendar_today, size: 16),
                //   label: Text(
                //     _isCalibrating ? 'Калибровка...' : 'Калибровать горизонт',
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue.shade800,
                //     foregroundColor: Colors.white,
                //     minimumSize: const Size(double.infinity, 40),
                //   ),
                // ),

                // const SizedBox(height: 10),

                // Сброс калибровки
                // TextButton(
                //   onPressed: () {
                //     setState(() {
                //       _calibrationOffset = 0.0;
                //     });
                //   },
                //   child: const Text(
                //     'Сбросить калибровку',
                //     style: TextStyle(color: Colors.grey),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Инициализация камеры...buildLoadingScreen',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerOverlay() {
    return CustomPaint(
      // painter: MarkerPainter(_detectedCenters),
      painter: MarkerPainter(
        _detectedCenters,
        _detectedLaserCenters,
        _transformCoordinates,
      ),
      child: Container(),
    );
  }
}

// class MarkerPainter extends CustomPainter {
//   final List<dartcv.Point2f> centers;

//   MarkerPainter(this.centers);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = const ui.Color.fromARGB(255, 216, 244, 54)
//           ..strokeWidth = 3
//           ..style = PaintingStyle.fill;

//     for (final center in centers) {
//       canvas.drawCircle(Offset(center.x, center.y), 8, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
class MarkerPainter extends CustomPainter {
  final List<dartcv.Point2f> detectedCenters;
  final List<dartcv.Point2f> detectedLaserCenters;
  final dartcv.Point2f Function(dartcv.Point2f) transformCoordinates;

  MarkerPainter(
    this.detectedCenters,
    this.detectedLaserCenters,
    this.transformCoordinates,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;
          // ..style = PaintingStyle.stroke;
          
    final testMarcker = transformCoordinates(dartcv.Point2f(320, 210));
    for (final center in detectedCenters) {
      // Преобразуем координаты из системы кадра в систему экрана
      final screenCenter = transformCoordinates(center);

      canvas.drawCircle(
        Offset(screenCenter.x, screenCenter.y),
        8.0, // радиус кружочка
        paint,
      );
    }
    for (final center in detectedLaserCenters) {
      // Преобразуем координаты из системы кадра в систему экрана
      final screenCenter = transformCoordinates(center);

      canvas.drawCircle(
        Offset(screenCenter.x, screenCenter.y),
        8.0, // радиус кружочка
        paint,
      );
    }
    canvas.drawCircle(
      Offset(testMarcker.x, testMarcker.y),
      8.0, // радиус кружочка
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
