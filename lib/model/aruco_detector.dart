// ================================================================
// ArUco detector
// ================================================================

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart';

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart';
import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart';

// Импортируйте необходимые зависимости
// import 'package:dartcv/dartcv.dart';
// import 'package:dartcv/contrib.dart';
// import 'package:ffi/ffi.dart' as ffi;

class ArucoCenterDetector {
  /// Возвращает список центров обнаруженных ArUco маркеров в координатах изображения
  /// Каждая точка имеет формат Offset(dx, dy) где dx, dy - нормализованные координаты [0..1]
  static List<Offset> detectArucoCenters(CameraImage image) {
    final centers = <Offset>[];

    try {
      // Шаг 1: Создание словаря. Используем один из предопределённых словарей.
      // Создаём объект словаря, например, для маркеров 6x6 с 250 вариантами.
      // Предполагается, что у вас есть доступ к функции для получения предопределённого словаря.
      final dictionary = ArucoDictionary.predefined(
        PredefinedDictionaryType.DICT_4X4_50,
      );
      // .getPredefinedDictionary(        cvg.DICT_6X6_250,      );

      // // Создаем детектор с правильными параметрами
      // final arucoDetector = ArucoDetector.withParams(
      //   getPredefinedDictionary(ArucoDictionary.dict4X4_50),
      //   DetectorParameters(),
      // );

      // Шаг 2: Создание параметров детектора. Можно использовать параметры по умолчанию.
      // В реальном приложении можно настроить параметры для оптимизации.
      // final parameters = ArucoDetectorParameters.empty();

      // // Настройка параметров
      // parameters.adaptiveThreshWinSizeMin = 3;
      // parameters.adaptiveThreshWinSizeMax = 23;
      // parameters.adaptiveThreshConstant = 7;
      // parameters.minMarkerPerimeterRate = 0.03;
      // parameters.maxMarkerPerimeterRate = 4.0;
      // parameters.cornerRefinementMethod = 2; // CORNER_REFINE_SUBPIX

      // Или использование пресета
      final fastParameters = ArucoParametersPreset.fast();
      // Шаг 3: Создание детектора ArUco с использованием словаря и параметров.
      final detector = ArucoDetector.create(dictionary, fastParameters);

      print('Детектор ArUco успешно создан.');

      // Конвертируем изображение в grayscale
      final grayMat = _convertToGrayscale(image);

      // Детектируем маркеры
      final corners = <Mat>[];
      final ids = Mat.empty();
      final rejected = <Mat>[];

      // arucoDetector.detectMarkers(
      //   image: grayMat,
      //   corners: corners,
      //   ids: ids,
      //   rejectedCandidates: rejected,
      // );

      try {
        // Использование детектора
        final (corners, ids, rejected) = detector.detectMarkers(grayMat);

        // // Вычисляем центры для каждого обнаруженного маркера
        // for (final corner in corners) {
        //   final center = _calculateMarkerCenter(
        //     corner,
        //     image.width,
        //     image.height,
        //   );
        //   if (center != null) {
        //     centers.add(center);
        //   }
        // }
        // !!!!!!!!!!!!!!!!!!
        // !!!!!!!!!!!!!!
        // !!!!!!!!!!!!!
        // Следующую строку поправить
        // final centers = _calculateMarkerCenters(corners);
      } finally {
        // Важно освободить все ресурсы
        detector.dispose();
        fastParameters.dispose();
        dictionary.dispose(); // если требуется
      }

      // Освобождаем ресурсы
      grayMat.release();
      // arucoDetector.release();
      for (final corner in corners) {
        corner.release();
      }
      for (final reject in rejected) {
        reject.release();
      }
      ids.release();
    } catch (e) {
      print('Error in ArUco detection: $e');
    }

    return centers;
  }

  // import 'package:camera/camera.dart';
  // import 'package:opencv_4/facade/core.dart';

  static Mat _convertToGrayscale(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420ToGrayscale(image);
    }
    // else if (image.format.group == ImageFormatGroup.bgra8888) {
    //   return _convertBGRAToGrayscale(image);
    // }
    // else if (image.format.group == ImageFormatGroup.jpeg) {
    //   return _convertJPEGToGrayscale(image);
    // }
    else {
      throw Exception('Unsupported image format: ${image.format.group}');
    }
  }

  static Mat _convertYUV420ToGrayscale(CameraImage image) {
    // YUV420: Y-плоскость уже содержит grayscale данные
    final yPlane = image.planes[0];
    final width = image.width;
    final height = image.height;

    // Создаем Mat из Y-плоскости
    final grayscale = Mat.fromList(
      height,
      width,
      MatType.CV_8UC1,
      yPlane.bytes,
    );
    // .fromData(
    //   (
    //   rows: height,
    //   cols: width,
    //   type: MatType.CV_8UC1,
    //   data: yPlane.bytes,
    // );

    return grayscale;
  }

  // static Mat _convertToGrayscale(CameraImage image) {
  //   if (image.format.group == ImageFormatGroup.yuv420) {
  //     // Для YUV420 используем только Y-плоскость (яркость)
  //     return Mat.fromPlanes(
  //       [image.planes[0]],
  //       image.height,
  //       image.width,
  //       MatType.CV_8UC1,
  //     );
  //   } else if (image.format.group == ImageFormatGroup.bgra8888) {
  //     // Для BGRA конвертируем в grayscale
  //     final bgraMat = Mat.fromPlanes(
  //       [image.planes[0]],
  //       image.height,
  //       image.width,
  //       MatType.CV_8UC4,
  //     );
  //     final grayMat = Imgproc.cvtColor(
  //       bgraMat,
  //       ColorConversionCodes.COLOR_BGRA2GRAY,
  //     );
  //     bgraMat.release();
  //     return grayMat;
  //   } else {
  //     // Для других форматов пытаемся использовать как BGR
  //     final colorMat = Mat.fromPlanes(
  //       [image.planes[0]],
  //       image.height,
  //       image.width,
  //       MatType.CV_8UC3,
  //     );
  //     final grayMat = Imgproc.cvtColor(
  //       colorMat,
  //       ColorConversionCodes.COLOR_BGR2GRAY,
  //     );
  //     colorMat.release();
  //     return grayMat;
  //   }
  // }

  List<Point2f> _calculateMarkerCenters(VecVecPoint2f corners) {
    final centers = <Point2f>[];

    for (int i = 0; i < corners.length; i++) {
      final markerCorners = corners[i];

      if (markerCorners.length == 4) {
        // Предполагаем, что углы идут в порядке: top-left, top-right, bottom-right, bottom-left
        final p1 = markerCorners[0]; // top-left
        final p2 = markerCorners[1]; // top-right
        final p3 = markerCorners[2]; // bottom-right
        final p4 = markerCorners[3]; // bottom-left

        // Вычисляем пересечение диагоналей
        final center = _lineIntersection(p1, p3, p2, p4);
        centers.add(center);
      }
    }

    return centers;
  }

  Point2f _lineIntersection(Point2f p1, Point2f p2, Point2f p3, Point2f p4) {
    // Вычисляем определители для нахождения точки пересечения
    final det = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x);

    if (det.abs() < 1e-10) {
      // Линии параллельны, возвращаем среднее
      return Point2f(
        (p1.x + p2.x + p3.x + p4.x) / 4,
        (p1.y + p2.y + p3.y + p4.y) / 4,
      );
    }

    final x =
        ((p1.x * p2.y - p1.y * p2.x) * (p3.x - p4.x) -
            (p1.x - p2.x) * (p3.x * p4.y - p3.y * p4.x)) /
        det;

    final y =
        ((p1.x * p2.y - p1.y * p2.x) * (p3.y - p4.y) -
            (p1.y - p2.y) * (p3.x * p4.y - p3.y * p4.x)) /
        det;

    return Point2f(x, y);
  }

  //   static Offset? _calculateMarkerCenter(
  //     Mat corners,
  //     int imageWidth,
  //     int imageHeight,
  //   ) {
  //     try {
  //       // Получаем данные углов
  //       final cornerData = corners.data;
  //       if (cornerData == null || cornerData.length < 8) return null;

  //       double sumX = 0;
  //       double sumY = 0;

  //       // corners содержит 4 точки по 2 координаты (x,y) каждая
  //       for (int i = 0; i < 8; i += 2) {
  //         sumX += cornerData[i]; // x координата
  //         sumY += cornerData[i + 1]; // y координата
  //       }

  //       // Вычисляем центр
  //       final centerX = sumX / 4;
  //       final centerY = sumY / 4;

  //       // Нормализуем координаты
  //       return Offset(centerX / imageWidth, centerY / imageHeight);
  //     } catch (e) {
  //       print('Error calculating marker center: $e');
  //       return null;
  //     }
  //   }
}

class ArucoParametersPreset {
  // Параметры для быстрого детектирования (меньшая точность)
  static ArucoDetectorParameters fast() {
    final params = ArucoDetectorParameters.empty();

    params.adaptiveThreshWinSizeMin = 3;
    params.adaptiveThreshWinSizeMax = 23;
    params.adaptiveThreshWinSizeStep = 10;
    params.adaptiveThreshConstant = 7;

    params.minMarkerPerimeterRate = 0.03;
    params.maxMarkerPerimeterRate = 4.0;

    params.polygonalApproxAccuracyRate = 0.05;
    params.minCornerDistanceRate = 0.05;

    params.cornerRefinementMethod = 0; // CORNER_REFINE_NONE

    return params;
  }

  // Параметры для точного детектирования (высокая точность)
  static ArucoDetectorParameters accurate() {
    final params = ArucoDetectorParameters.empty();

    params.adaptiveThreshWinSizeMin = 3;
    params.adaptiveThreshWinSizeMax = 23;
    params.adaptiveThreshWinSizeStep = 10;
    params.adaptiveThreshConstant = 7;

    params.minMarkerPerimeterRate = 0.03;
    params.maxMarkerPerimeterRate = 4.0;

    params.polygonalApproxAccuracyRate = 0.01;
    params.minCornerDistanceRate = 0.01;

    params.cornerRefinementMethod = 2; // CORNER_REFINE_SUBPIX
    params.cornerRefinementWinSize = 5;
    params.cornerRefinementMaxIterations = 30;
    params.cornerRefinementMinAccuracy = 0.1;

    return params;
  }

  // Параметры для сложных условий (низкая освещенность, шум)
  static ArucoDetectorParameters challengingConditions() {
    final params = ArucoDetectorParameters.empty();

    params.adaptiveThreshWinSizeMin = 3;
    params.adaptiveThreshWinSizeMax = 43;
    params.adaptiveThreshWinSizeStep = 10;
    params.adaptiveThreshConstant = 2;

    params.minMarkerPerimeterRate = 0.02;
    params.maxMarkerPerimeterRate = 4.0;

    params.polygonalApproxAccuracyRate = 0.03;
    params.minCornerDistanceRate = 0.02;

    params.minOtsuStdDev = 5.0;
    params.errorCorrectionRate = 0.6;

    return params;
  }
}
// 1111111111111111111111111111111111111111111111111111111111111111
// 1111111111111111111111111111111111111111111111111111111111111
// 11111111111111111111111111111111111111111111111111111111111

// class ArucoDetectorService {
//   final ArucoDetector detector;
//   final ArucoDetectorParameters parameters;
//   final ArucoDictionary dictionary;

//   ArucoDetectorService()
//     : dictionary = ArucoDictionary.predefined(
//         PredefinedDictionaryType.DICT_4X4_50,
//       ),
//       parameters = ArucoParametersPreset.accurate(),
//       detector = ArucoDetector.create(
//         ArucoDictionary.predefined(PredefinedDictionaryType.DICT_4X4_50),
//         ArucoParametersPreset.accurate(),
//       );

//   List<Point2f> processFrame(CameraImage image) {
//     List<Point2f> centers = [];
//     Mat grayMat = Mat.empty();

//     try {
//       grayMat = _convertToGrayscale(image);
//       final (corners, ids, rejected) = detector.detectMarkers(grayMat);

//       try {
//         centers = _calculateMarkerCenters(corners);
//       } finally {
//         corners.dispose();
//         ids.dispose();
//         rejected.dispose();
//       }
//     } catch (e) {
//       print('Aruco detection error: $e');
//     } finally {
//       grayMat.dispose();
//     }

//     return centers;
//   }

//   void dispose() {
//     detector.dispose();
//     parameters.dispose();
//     dictionary.dispose();
//   }

//   static Mat _convertToGrayscale(CameraImage image) {
//     if (image.format.group == ImageFormatGroup.yuv420) {
//       return _convertYUV420ToGrayscale(image);
//     } else {
//       throw Exception('Unsupported image format: ${image.format.group}');
//     }
//   }

//   static Mat _convertYUV420ToGrayscale(CameraImage image) {
//     // YUV420: Y-плоскость уже содержит grayscale данные
//     final yPlane = image.planes[0];
//     final width = image.width;
//     final height = image.height;

//     // Создаем Mat из Y-плоскости
//     final grayscale = Mat.fromList(
//       height,
//       width,
//       MatType.CV_8UC1,
//       yPlane.bytes,
//     );
//     return grayscale;
//   }

//   List<Point2f> _calculateMarkerCenters(VecVecPoint2f corners) {
//     final centers = <Point2f>[];

//     for (int i = 0; i < corners.length; i++) {
//       final markerCorners = corners[i];

//       if (markerCorners.length == 4) {
//         // Предполагаем, что углы идут в порядке: top-left, top-right, bottom-right, bottom-left
//         final p1 = markerCorners[0]; // top-left
//         final p2 = markerCorners[1]; // top-right
//         final p3 = markerCorners[2]; // bottom-right
//         final p4 = markerCorners[3]; // bottom-left

//         // Вычисляем пересечение диагоналей
//         final center = _lineIntersection(p1, p3, p2, p4);
//         centers.add(center);
//       }
//     }

//     return centers;
//   }

//   Point2f _lineIntersection(Point2f p1, Point2f p2, Point2f p3, Point2f p4) {
//     // Вычисляем определители для нахождения точки пересечения
//     final det = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x);

//     if (det.abs() < 1e-10) {
//       // Линии параллельны, возвращаем среднее
//       return Point2f(
//         (p1.x + p2.x + p3.x + p4.x) / 4,
//         (p1.y + p2.y + p3.y + p4.y) / 4,
//       );
//     }

//     final x =
//         ((p1.x * p2.y - p1.y * p2.x) * (p3.x - p4.x) -
//             (p1.x - p2.x) * (p3.x * p4.y - p3.y * p4.x)) /
//         det;

//     final y =
//         ((p1.x * p2.y - p1.y * p2.x) * (p3.y - p4.y) -
//             (p1.y - p2.y) * (p3.x * p4.y - p3.y * p4.x)) /
//         det;

//     return Point2f(x, y);
//   }
// }

// 222222222222222222222222222222222222222222222222222222222222222
// 222222222222222222222222222222222222222222222222222222222222222
// 222222222222222222222222222222222222222222222222222222222222222
class ArucoDetectorService {
  late ArucoDetector _detector;
  late ArucoDictionary _dictionary;
  late ArucoDetectorParameters _parameters;

  ArucoDetectorService() {
    _dictionary = ArucoDictionary.predefined(
      PredefinedDictionaryType.DICT_4X4_50,
    );
    _parameters = ArucoParametersPreset.accurate();
    _detector = ArucoDetector.create(_dictionary, _parameters);
  }

  List<Point2f> processFrame(CameraImage image) {
    final grayMat = _convertToGrayscale(image);
    final centers = <Point2f>[];

    try {
      // Детектируем маркеры
      final (corners, ids, rejected) = _detector.detectMarkers(grayMat);

      // Вычисляем центры
      for (int i = 0; i < corners.length; i++) {
        final markerCorners = corners[i];
        if (markerCorners.length == 4) {
          double centerX = 0.0;
          double centerY = 0.0;

          for (final corner in markerCorners) {
            centerX += corner.x;
            centerY += corner.y;
          }

          centers.add(Point2f(centerX / 4, centerY / 4));
        }
      }
    } catch (e) {
      print('Aruco detection error: $e');
    } finally {
      grayMat.release();
    }

    return centers;
  }

  Mat _convertToGrayscale(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      final yPlane = image.planes[0];

      // Создаем Mat из Y-плоскости
      return Mat.fromList(
        image.height,
        image.width,
        MatType.CV_8UC1,
        yPlane.bytes,
      );
    }

    else {
      throw Exception('Unsupported image format: ${image.format.group}');
    }
  }

  void dispose() {
    _detector.dispose(); //.release();
    _dictionary.dispose(); //.release();
    _parameters.dispose(); //.release();
  }
}
