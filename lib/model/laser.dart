import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:typed_data';

// 222222222222222222222222222222222222222222222222222222222222222
// 222222222222222222222222222222222222222222222222222222222222222
// 222222222222222222222222222222222222222222222222222222222222222
class LaserDetectorService {
  LaserDetectorService() {}

  // List<Point2f> processFrame(CameraImage image) {
  //   final grayMat = _convertToGrayscale(image);
  //   final centers = <Point2f>[];

  //   try {
  //     // Детектируем маркеры
  //     final (corners, ids, rejected) = _detector.detectMarkers(grayMat);

  //     // Вычисляем центры
  //     for (int i = 0; i < corners.length; i++) {
  //       final markerCorners = corners[i];
  //       if (markerCorners.length == 4) {
  //         double centerX = 0.0;
  //         double centerY = 0.0;

  //         for (final corner in markerCorners) {
  //           centerX += corner.x;
  //           centerY += corner.y;
  //         }

  //         centers.add(Point2f(centerX / 4, centerY / 4));
  //       }
  //     }
  //   } catch (e) {
  //     print('Aruco detection error: $e');
  //   } finally {
  //     grayMat.release();
  //   }

  //   return centers;
  // }

  /// Основная функция обработки кадра, которая находит центры лазерных пятен.
  List<cv.Point2f> processLaserFrame(CameraImage image) {
    List<cv.Point2f> laserCenters = [];
    // cv.Mat? hsvImage;
    // cv.Mat? mask1;
    // cv.Mat? mask2;
    // cv.Mat? redMask;
    // cv.Mat? kernel;

    // // Добавляем переменные для границ цвета:
    // cv.Mat? lowerRed1;
    // cv.Mat? upperRed1;
    // cv.Mat? lowerRed2;
    // cv.Mat? upperRed2;
    // cv.Mat? openedMask;
    // cv.Mat? closedMask;

    // // List<cv.Mat>? contours;
    // dynamic contours;

    // try {

    //  printPixelYUV(CameraImage image, int i, int j)
    printPixelYUV(image, 320, 210);

    //   // 1. Преобразуем CameraImage в Mat в формате HSV
    //   hsvImage = _convertToHSV(image);

    //   if (hsvImage.isEmpty) {
    //     print("Failed to convert image to HSV.");
    //     return laserCenters;
    //   }

    //   // 2. Определяем диапазоны для красного цвета в HSV (красный цвет на границе шкалы Hue 0-180)

    //   // // Нижний красный диапазон: Hue 0-10
    //   // mask1 = cv.inRange(hsvImage, cv.Scalar(0, 100, 100), cv.Scalar(10, 255, 255));
    //   // // Верхний красный диапазон: Hue 170-180
    //   // mask2 = cv.inRange(hsvImage, cv.Scalar(170, 100, 100), cv.Scalar(180, 255, 255));

    //   // Создаем Mat для нижнего диапазона HSV
    //   // lowerRed1 = cv.Mat.fromNativeScalar(cv.Scalar(0, 100, 100));
    //   // upperRed1 = cv.Mat.fromNativeScalar(cv.Scalar(10, 255, 255));
    //   //     lowerRed1 = cv.Mat.fromRgba(0, 100, 100);
    //   // upperRed1 = cv.Mat.fromRgba(10, 255, 255);
    //   //     lowerRed1 = cv.Mat.fromVec([0.0, 100.0, 100.0], cv.MatType.CV_64FC1);
    //   // upperRed1 = cv.Mat.fromVec([10.0, 255.0, 255.0], cv.MatType.CV_64FC1);
    //   // lowerRed1 = cv.Mat.fromVec(cv.Vec4d(0.0, 100.0, 100.0, 0.0));
    //   // upperRed1 = cv.Mat.fromVec(cv.Vec4d(10.0, 255.0, 255.0, 0.0));

    //   // final cv.Scalar lowerRed1 = cv.Scalar(0, 100, 100);
    //   // final cv.Scalar upperRed1 = cv.Scalar(10, 255, 255);
    //   // final cv.Scalar lowerRed2 = cv.Scalar(170, 100, 100);
    //   // final cv.Scalar upperRed2 = cv.Scalar(180, 255, 255);

    //   // Создаем Mat для верхнего диапазона HSV
    //   // lowerRed2 = cv.Mat.fromNativeScalar(cv.Scalar(170, 100, 100));
    //   // upperRed2 = cv.Mat.fromNativeScalar(cv.Scalar(180, 255, 255));
    //   //     lowerRed2 = cv.Mat.fromRgba(170, 100, 100);
    //   // upperRed2 = cv.Mat.fromRgba(180, 255, 255);

    //   // // Нижний красный диапазон
    //   // mask1 = cv.inRange(hsvImage!, lowerRed1!, upperRed1!);
    //   // // Верхний красный диапазон
    //   // mask2 = cv.inRange(hsvImage, lowerRed2!, upperRed2!);

    //   //  mask1 = cv.inRange(hsvImage, lowerRed1, upperRed1);
    //   //   mask2 = cv.inRange(hsvImage, lowerRed2, upperRed2);

    //   // lowerRed1 = cv.Mat.fromList([0, 100, 100]);
    //   // upperRed1 = cv.Mat.fromList([10, 255, 255]);
    //   // lowerRed2 = cv.Mat.fromList([170, 100, 100]);
    //   // upperRed2 = cv.Mat.fromList([180, 255, 255]);

    //   lowerRed1 = cv.Mat.fromList(1, 1, cv.MatType.CV_8UC3, [0, 100, 100]);
    //   upperRed1 = cv.Mat.fromList(1, 1, cv.MatType.CV_8UC3, [10, 255, 255]);
    //   lowerRed2 = cv.Mat.fromList(1, 1, cv.MatType.CV_8UC3, [170, 100, 100]);
    //   upperRed2 = cv.Mat.fromList(1, 1, cv.MatType.CV_8UC3, [180, 255, 255]);

    //   // Теперь передаем Mat в функцию inRange, как того требует сигнатура:
    //   mask1 = cv.inRange(hsvImage, lowerRed1!, upperRed1!);
    //   mask2 = cv.inRange(hsvImage, lowerRed2!, upperRed2!);

    //   // 3. Комбинируем маски с помощью побитового ИЛИ
    //   // redMask = cv.bitwiseOr(mask1, mask2);
    //   // redMask = cv.bitwiseOr(mask1!, mask2!);
    //   // redMask = cv.Core.bitwiseOr(mask1, mask2);
    //   redMask = cv.bitwiseOR(mask1!, mask2!);

    //   // 4. Применяем морфологические операции для удаления шума и объединения пятен
    //   // kernel = cv.Mat.ones(5, 5, cv.MatType.CV_8U);
    //   // kernel = cv.Mat.ones(5, 5, cv.MatType.fromValue(cv.MatType.CV_8U));
    //   kernel = cv.Mat.ones(5, 5, cv.MatType(cv.MatType.CV_8U));

    //   // MORPH_OPEN убирает мелкий шум
    //   // cv.Mat openedMask = cv.morphologyEx(redMask, cv.MORPH_OPEN, kernel);
    //   openedMask = cv.morphologyEx(redMask!, cv.MORPH_OPEN, kernel!);
    //   // MORPH_CLOSE объединяет близкие точки в одно пятно
    //   // cv.Mat closedMask = cv.morphologyEx(openedMask, cv.MORPH_CLOSE, kernel);
    //   closedMask = cv.morphologyEx(openedMask, cv.MORPH_CLOSE, kernel);

    //   // 5. Находим контуры объектов на маске
    //   // final contours = <cv.Mat>[];
    //   // cv.findContours изменяет closedMask, поэтому используем ее как источник
    //   // cv.findContours(
    //   //   closedMask,
    //   //   contours,
    //   //   cv.RETR_EXTERNAL,
    //   //   cv.CHAIN_APPROX_SIMPLE,
    //   // );
    //   // cv.findContours(closedMask!, contours, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    //   final result = cv.findContours(
    //     closedMask!,
    //     cv.RETR_EXTERNAL,
    //     cv.CHAIN_APPROX_SIMPLE,
    //   );
    //   contours =
    //       result.$1; // Первый элемент кортежа - это список контуров (VecVecPoint)
    //   // final hierarchy = result.$2; // Второй элемент кортежа - иерархия, нам она не нужна

    //   // 6. Фильтруем контуры по площади и вычисляем центры

    //   for (final contour in contours!) {
    //     // contour теперь это отдельный Mat
    //     double area = cv.contourArea(contour);

    //     if (area > 100.0 && area < 5000.0) {
    //       final moments = cv.moments(contour);

    //       if (moments.m00 != 0) {
    //         double centerX = moments.m10 / moments.m00;
    //         double centerY = moments.m01 / moments.m00;
    //         laserCenters.add(cv.Point2f(centerX, centerY));
    //       }
    //     }
    //     // ОЧИЩАЕМ ЗДЕСЬ
    //     contour.dispose();
    //   }

    //   laserCenters.sort((a, b) => a.x.compareTo(b.x));

    //   // 👇 ДОБАВЛЯЕМ ПЕЧАТЬ В КОНСОЛЬ ЗДЕСЬ 👇
    //   if (laserCenters.isEmpty) {
    //     print("Лазерные пятна не найдены.");
    //   } else {
    //     print("Найдены координаты лазеров:");
    //     for (var center in laserCenters) {
    //       print(
    //         center.toString(),
    //       ); // Использует переопределенный toString() в классе Point2f
    //     }
    //   }
    //   // 👆 КОНЕЦ БЛОКА ПЕЧАТИ 👆
    // } catch (e) {
    //   print('Error in processFrame: $e');
    // } finally {
    //   // 7. Очищаем память ВСЕГДА
    //   hsvImage?.dispose();
    //   mask1?.dispose();
    //   mask2?.dispose();
    //   redMask?.dispose();
    //   kernel?.dispose();
    //   openedMask?.dispose();
    //   closedMask?.dispose();
    //   // openedMask и closedMask автоматически очищаются, т.к. были использованы внутри findContours
    //   // Очищаем матрицы границ цвета:
    //   lowerRed1?.dispose();
    //   upperRed1?.dispose();
    //   lowerRed2?.dispose();
    //   upperRed2?.dispose();
    //   contours.dispose();
    // }

    return laserCenters;
  }

  // Mat _convertToGrayscale(CameraImage image) {
  //   if (image.format.group == ImageFormatGroup.yuv420) {
  //     final yPlane = image.planes[0];

  //     // Создаем Mat из Y-плоскости
  //     return Mat.fromList(
  //       image.height,
  //       image.width,
  //       MatType.CV_8UC1,
  //       yPlane.bytes,
  //     );
  //   }

  //   else {
  //     throw Exception('Unsupported image format: ${image.format.group}');
  //   }
  // }

  // /// Преобразует CameraImage в Mat в формате HSV
  // /// Это работало, но падало с ошибкой
  // cv.Mat _convertToHSV(CameraImage image) {
  //   cv.Mat? src;
  //   // cv.Mat? hsvMat;

  //   try {
  //     if (image.format.group == ImageFormatGroup.yuv420) {
  //       final int width = image.width;
  //       final int height = image.height;

  //       // Объединяем YUV Planes в один массив байтов
  //       // (Подход зависит от конкретного формата YUV, этот - для NV21/NV12)
  //       final Uint8List bytes = Uint8List.fromList([
  //         ...image.planes[0].bytes, // Y plane
  //         ...image.planes[1].bytes, // UV/VU plane
  //       ]);

  //       // Используем актуальный метод Mat.fromUint8List
  //       // Высота YUV изображения для NV21/NV12 равна высоте + половина высоты (height * 1.5)
  //       src = cv.Mat.fromList(height * 3 ~/ 2, width, cv.MatType.CV_8UC1, bytes);

  //       // Конвертируем YUV в BGR
  //       // cv.Mat bgrMat = cv.Mat.empty();
  //       // cv.cvtColor(src!, bgrMat, cv.COLOR_YUV2BGR_NV21);
  //       cv.Mat bgrMat = cv.cvtColor(src!, cv.COLOR_YUV2BGR_NV21);

  //       // Конвертируем BGR в HSV
  //       // hsvMat = cv.Mat.empty();
  //       // cv.cvtColor(bgrMat, hsvMat!, cv.COLOR_BGR2HSV);
  //       cv.Mat hsvMat = cv.cvtColor(bgrMat, cv.COLOR_BGR2HSV);

  //       // Очищаем временную BGR матрицу
  //       bgrMat.dispose();
  //       src!.dispose(); // src тоже временный

  //       return hsvMat;
  //     } else if (image.format.group == ImageFormatGroup.bgra8888) {
  //       final int width = image.width;
  //       final int height = image.height;

  //       // Используем актуальный метод Mat.fromUint8List для BGRA
  //       src = cv.Mat.fromList(
  //         height,
  //         width,
  //         cv.MatType.CV_8UC4,
  //         image.planes[0].bytes,
  //       );

  //       // cv.Mat bgrMat = cv.Mat.empty();
  //       // cv.cvtColor(src!, bgrMat, cv.COLOR_BGRA2BGR);

  //       // hsvMat = cv.Mat.empty();
  //       // cv.cvtColor(bgrMat, hsvMat!, cv.COLOR_BGR2HSV);
  //       cv.Mat bgrMat = cv.cvtColor(src!, cv.COLOR_BGRA2BGR);

  //       cv.Mat hsvMat = cv.cvtColor(bgrMat, cv.COLOR_BGR2HSV);

  //       bgrMat.dispose();
  //       src!.dispose();
  //       return hsvMat;
  //     } else {
  //       throw Exception('Unsupported image format: ${image.format.group}');
  //     }
  //   } catch (e) {
  //     print('Error converting CameraImage to HSV Mat: $e');
  //     src?.dispose();
  //     rethrow;
  //   }
  // }

  // cv.Mat _convertToHSV(CameraImage image) {
  //   try {
  //     if (image.planes.isEmpty) {
  //       return cv.Mat.empty();
  //     }

  //     // Пробуем декодировать как JPEG/BGR
  //     cv.Mat bgrMat = cv.imdecode(image.planes[0].bytes, cv.ImreadModes.color);

  //     if (bgrMat.empty) {
  //       return cv.Mat.empty();
  //     }

  //     // Конвертируем BGR в HSV
  //     cv.Mat hsvMat = cv.Mat.empty();
  //     cv.cvtColor(bgrMat, hsvMat, cv.ColorConversionCodes.bgr2hsv.value);
  //     bgrMat.release();

  //     return hsvMat;
  //   } catch (e) {
  //     print('Error in _convertToHSV: $e');
  //     return cv.Mat.empty();
  //   }
  // }

  void dispose() {
    // _detector.dispose(); //.release();
    // _dictionary.dispose(); //.release();
    // _parameters.dispose(); //.release();
  }
}

void printPixelYUV(CameraImage image, int i, int j) {
  if (image.format.group != ImageFormatGroup.yuv420) {
    print("This function only supports YUV420 format.");
    return;
  }

  final int width = image.width ?? 0;
  final int height = image.height ?? 0;

  if (i < 0 || i >= width || j < 0 || j >= height) {
    print("Coordinates (i, j) are out of bounds.");
    return;
  }

  // 1. Получаем данные из планов
  final Uint8List bytesY = image.planes[0].bytes;
  final Uint8List bytesU = image.planes[1].bytes;
  final Uint8List bytesV = image.planes[2].bytes;

  // 2. Рассчитываем смещения (Offsets)
  // Y-план имеет полное разрешение:
  final int offsetY = j * width + i;
  final int yValue = bytesY[offsetY];

  // U и V планы имеют половинное разрешение (Subsampled 4:2:0),
  // то есть 1x1 блок цветности на 2x2 блока яркости.
  // Делим координаты на 2, чтобы попасть в правильный блок цветности:
  final int uIndex = (j ~/ 2) * (width ~/ 2) + (i ~/ 2);
  final int vIndex = (j ~/ 2) * (width ~/ 2) + (i ~/ 2);

  // В зависимости от bytesPerPixel (2 в вашем случае), вам может понадобиться
  // скорректировать индекс, но для простых планарных данных (p)
  // индекс обычно прямой:
  final int uValue = bytesU[uIndex];
  final int vValue = bytesV[vIndex];

  // 3. Печатаем результат в терминал
  // print('--- Pixel ($i, $j) YUV Values ---');
  // print('Y (Luma)  : $yValue');
  // print('U (Chroma): $uValue');
  // print('V (Chroma): $vValue');
  // print('----------------------------------');
  // print('------------------------------------------------------ Pixel ($i, $j)   Y : $yValue  U : $uValue  V : $vValue    -------------------');
  print('($i, $j)[$yValue][${uValue-128}][${vValue-128}]');
}







// /// Основная функция обработки кадра, которая находит центры лазерных пятен.
// List<cv.Point2f> processFrame(CameraImage image) {
//   List<cv.Point2f> laserCenters = [];
//   cv.Mat? hsvImage;
//   cv.Mat? mask1;
//   cv.Mat? mask2;
//   cv.Mat? redMask;
//   cv.Mat? kernel;

//   try {
//     // 1. Преобразуем CameraImage в Mat в формате HSV
//     hsvImage = _convertToHSV(image);
    
//     if (hsvImage.isEmpty) {
//       print("Failed to convert image to HSV.");
//       return laserCenters;
//     }
    
//     // 2. Определяем диапазоны для красного цвета в HSV (красный цвет на границе шкалы Hue 0-180)
    
//     // Нижний красный диапазон: Hue 0-10
//     mask1 = cv.inRange(hsvImage, cv.Scalar(0, 100, 100), cv.Scalar(10, 255, 255));
//     // Верхний красный диапазон: Hue 170-180
//     mask2 = cv.inRange(hsvImage, cv.Scalar(170, 100, 100), cv.Scalar(180, 255, 255));
    
//     // 3. Комбинируем маски с помощью побитового ИЛИ
//     redMask = cv.bitwiseOr(mask1, mask2);
    
//     // 4. Применяем морфологические операции для удаления шума и объединения пятен
//     kernel = cv.Mat.ones(5, 5, cv.MatType.CV_8U);
//     // MORPH_OPEN убирает мелкий шум
//     cv.Mat openedMask = cv.morphologyEx(redMask, cv.MORPH_OPEN, kernel);
//     // MORPH_CLOSE объединяет близкие точки в одно пятно
//     cv.Mat closedMask = cv.morphologyEx(openedMask, cv.MORPH_CLOSE, kernel);
    
//     // 5. Находим контуры объектов на маске
//     final contours = <cv.Mat>[];
//     // cv.findContours изменяет closedMask, поэтому используем ее как источник
//     cv.findContours(closedMask, contours, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    
//     // 6. Фильтруем контуры по площади и вычисляем центры
//     for (final contour in contours) {
//       double area = cv.contourArea(contour);
      
//       // Фильтр по минимальной площади (настройте значение 100.0 под ваши пятна)
//       if (area > 100.0 && area < 5000.0) {
//         // Вычисляем моменты контура (для поиска центра масс)
//         final moments = cv.moments(contour);
        
//         if (moments.m00 != 0) {
//           double centerX = moments.m10 / moments.m00;
//           double centerY = moments.m01 / moments.m00;
          
//           laserCenters.add(cv.Point2f(centerX, centerY));
//         }
//       }
//       // ОЧЕНЬ ВАЖНО: Очищаем каждый отдельный контур Mat
//       contour.dispose();
//     }
    
//     // Сортируем центры по X координате, чтобы всегда возвращать "левый" и "правый" лазеры
//     laserCenters.sort((a, b) => a.x.compareTo(b.x));

//   } catch (e) {
//     print('Error in processFrame: $e');
//   } finally {
//     // 7. Очищаем память ВСЕГДА
//     hsvImage?.dispose();
//     mask1?.dispose();
//     mask2?.dispose();
//     redMask?.dispose();
//     kernel?.dispose();
//     // openedMask и closedMask автоматически очищаются, т.к. были использованы внутри findContours
//   }
  
//   return laserCenters;
// }





















// List<Point2f> processLaserFrame(CameraImage image) {
//   List<Point2f> laserCenters = [];

//   try {
//     // Конвертируем CameraImage в Mat
//     Mat src = _cameraImageToMat(image);

//     // Конвертируем в HSV для лучшего выделения красного цвета
//     Mat hsv = Mat.empty();
//     cvtColor(src, hsv, ColorConversionCodes.bgr2hsv.value);

//     // Определяем диапазоны для красного цвета в HSV
//     Mat mask1 = Mat.empty();
//     Mat mask2 = Mat.empty();
//     Mat redMask = Mat.empty();

//     // Нижний красный диапазон
//     inRange(hsv, Scalar.all(0), Scalar(10, 255, 255, 0), mask1);
//     // Верхний красный диапазон
//     inRange(hsv, Scalar(170, 120, 70, 0), Scalar(180, 255, 255, 0), mask2);

//     // Комбинируем маски
//     bitwiseOr(mask1, mask2, redMask);

//     // Морфологические операции для удаления шума
//     Mat kernel = Mat.ones(Size(5, 5), MatType.CV_8U);
//     morphologyEx(redMask, redMask, MorphTypes.open, kernel);
//     morphologyEx(redMask, redMask, MorphTypes.close, kernel);

//     // Находим контуры
//     List<MatOfPoint> contours = [];
//     Mat hierarchy = Mat.empty();
//     findContours(
//       redMask,
//       contours,
//       hierarchy,
//       RetrievalModes.external,
//       ContourApproximationModes.simple,
//     );

//     // Фильтруем контуры по площади и находим центры
//     for (int i = 0; i < contours.length; i++) {
//       double area = contourArea(contours[i]);

//       // Фильтр по минимальной площади
//       if (area > 100.0) {
//         // Вычисляем моменты контура
//         Moments moments = moments(contours[i]);

//         if (moments.m00 != 0) {
//           double centerX = moments.m10 / moments.m00;
//           double centerY = moments.m01 / moments.m00;

//           laserCenters.add(Point2f(centerX, centerY));
//         }
//       }
//     }

//     // Очищаем память
//     src.release();
//     hsv.release();
//     mask1.release();
//     mask2.release();
//     redMask.release();
//     kernel.release();
//     hierarchy.release();
//   } catch (e) {
//     print('Error in processFrame: $e');
//   }

//   return laserCenters;
// }

// // Вспомогательная функция для конвертации CameraImage в Mat
// Mat _cameraImageToMat(CameraImage image) {
//   try {
//     if (image.format.group == ImageFormatGroup.yuv420) {
//       return _convertYUV420ToMat(image);
//     } else if (image.format.group == ImageFormatGroup.bgra8888) {
//       return _convertBGRA8888ToMat(image);
//     } else if (image.format.group == ImageFormatGroup.jpeg) {
//       return _convertJPEGToMat(image);
//     } else if (image.format.group == ImageFormatGroup.nv21) {
//       return _convertYUV420ToMat(image);
//     }
//   } catch (e) {
//     print('Error converting CameraImage to Mat: $e');
//   }

//   return Mat.empty();
// }

// Mat _convertYUV420ToMat(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;

//   try {
//     // Для YUV420 создаем Mat из данных Y-плоскости
//     if (image.planes.length < 1) return Mat.empty();

//     // Создаем Mat из Y-компоненты
//     Mat yMat = Mat.fromBytes(
//       height,
//       width,
//       MatType.CV_8UC1,
//       image.planes[0].bytes,
//     );

//     // Если есть UV-плоскости, обрабатываем их
//     if (image.planes.length >= 2) {
//       Mat uvMat = Mat.fromBytes(
//         height ~/ 2,
//         width ~/ 2,
//         MatType.CV_8UC2,
//         image.planes[1].bytes,
//       );

//       // Конвертируем YUV в BGR
//       Mat bgrMat = Mat.empty();
//       cvtColorTwoPlane(
//         yMat,
//         uvMat,
//         bgrMat,
//         ColorConversionCodes.yuv2bgr_NV21.value,
//       );

//       yMat.release();
//       uvMat.release();
//       return bgrMat;
//     } else {
//       // Если только Y-плоскость, конвертируем в grayscale
//       Mat bgrMat = Mat.empty();
//       cvtColor(yMat, bgrMat, ColorConversionCodes.gray2bgr.value);
//       yMat.release();
//       return bgrMat;
//     }
//   } catch (e) {
//     print('Error in _convertYUV420ToMat: $e');
//     return Mat.empty();
//   }
// }

// Mat _convertBGRA8888ToMat(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;

//   try {
//     if (image.planes.isEmpty) return Mat.empty();

//     Mat mat = Mat.fromBytes(
//       height,
//       width,
//       MatType.CV_8UC4,
//       image.planes[0].bytes,
//     );
//     Mat bgrMat = Mat.empty();

//     cvtColor(mat, bgrMat, ColorConversionCodes.bgra2bgr.value);

//     mat.release();
//     return bgrMat;
//   } catch (e) {
//     print('Error in _convertBGRA8888ToMat: $e');
//     return Mat.empty();
//   }
// }

// Mat _convertJPEGToMat(CameraImage image) {
//   try {
//     if (image.planes.isEmpty) return Mat.empty();

//     // Для JPEG используем imdecode
//     return imdecode(image.planes[0].bytes, ImreadModes.color);
//   } catch (e) {
//     print('Error in _convertJPEGToMat: $e');
//     return Mat.empty();
//   }
// }

// // Класс Point2f для представления точки с координатами float
// class Point2f {
//   final double x;
//   final double y;

//   Point2f(this.x, this.y);

//   @override
//   String toString() => 'Point2f($x, $y)';
// }















// import 'package:camera/camera.dart';
// import 'package:opencv_dart/opencv_dart.dart' as cv;
// import 'dart:typed_data';

// // Класс Point2f для представления точки с координатами float
// // Оставлен как был, т.к. opencv_dart использует свой cv.Point2f
// class Point2f {
//   final double x;
//   final double y;
  
//   Point2f(this.x, this.y);
  
//   @override
//   String toString() => 'Point2f($x, $y)';
// }

// /// Обрабатывает кадр с камеры и находит координаты пятен лазера.
// List<Point2f> processLaserFrame(CameraImage image) {
//   List<Point2f> laserCenters = [];
//   cv.Mat? src;
//   cv.Mat? hsv;
//   cv.Mat? mask1;
//   cv.Mat? mask2;
//   cv.Mat? redMask;
//   cv.Mat? kernel;
//   // cv.Mat hierarchy; // hierarchy не требует ручной очистки в List<MatOfPoint> context

//   try {
//     // 1. Конвертируем CameraImage в Mat
//     src = _cameraImageToMat(image);
    
//     if (src == null || src.isEmpty) {
//       print("Failed to convert CameraImage to Mat.");
//       return laserCenters;
//     }

//     // 2. Конвертируем в HSV для лучшего выделения красного цвета
//     hsv = cv.Mat.empty();
//     cv.cvtColor(src, hsv!, cv.COLOR_BGR2HSV);
    
//     // 3. Определяем диапазоны для красного цвета в HSV
//     mask1 = cv.Mat.empty();
//     mask2 = cv.Mat.empty();
//     redMask = cv.Mat.empty();
    
//     // Нижний красный диапазон
//     cv.inRange(hsv!, cv.Scalar(0, 120, 70), cv.Scalar(10, 255, 255), mask1!);
//     // Верхний красный диапазон  
//     cv.inRange(hsv, cv.Scalar(170, 120, 70), cv.Scalar(180, 255, 255), mask2!);
    
//     // 4. Комбинируем маски
//     cv.bitwiseOr(mask1, mask2, redMask!);
    
//     // 5. Морфологические операции для удаления шума
//     kernel = cv.Mat.ones(5, 5, cv.CV_8U); // Используем cv.Mat.ones
//     cv.morphologyEx(redMask, redMask, cv.MORPH_OPEN, kernel!);
//     cv.morphologyEx(redMask, redMask, cv.MORPH_CLOSE, kernel);
    
//     // 6. Находим контуры
//     final contours = <cv.Mat>[]; // opencv_dart использует List<Mat> для контуров
//     // hierarchy = cv.Mat.empty(); // Hierarchy создается внутри findContours и не требует ручной очистки
//     cv.findContours(redMask, contours, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    
//     // 7. Фильтруем контуры по площади и находим центры
//     for (final contour in contours) {
//       double area = cv.contourArea(contour);
      
//       // Фильтр по минимальной площади (настраиваем под ваш случай)
//       if (area > 100.0) {
//         // Вычисляем моменты контура
//         final moments = cv.moments(contour);
        
//         if (moments.m00 != 0) {
//           double centerX = moments.m10 / moments.m00;
//           double centerY = moments.m01 / moments.m00;
          
//           laserCenters.add(Point2f(centerX, centerY));
//         }
//       }
//       // ОЧЕНЬ ВАЖНО: Очищаем каждый отдельный контур Mat
//       contour.dispose();
//     }
    
//   } catch (e) {
//     print('Error in processFrame: $e');
//   } finally {
//     // 8. Очищаем память ВСЕГДА (даже если была ошибка)
//     src?.dispose();
//     hsv?.dispose();
//     mask1?.dispose();
//     mask2?.dispose();
//     redMask?.dispose();
//     kernel?.dispose();
//     // hierarchy.dispose(); // Не нужно, см. выше
//   }
  
//   return laserCenters;
// }

// // Вспомогательная функция для конвертации CameraImage в Mat
// cv.Mat? _cameraImageToMat(CameraImage image) {
//   try {
//     if (image.format.group == ImageFormatGroup.yuv420) {
//       return _convertYUV420ToMat(image);
//     } else if (image.format.group == ImageFormatGroup.bgra8888) {
//       return _convertBGRA8888ToMat(image);
//     } else if (image.format.group == ImageFormatGroup.jpeg) {
//       return _convertJPEGToMat(image);
//     }
//   } catch (e) {
//     print('Error converting CameraImage to Mat: $e');
//   }
//   return null;
// }

// cv.Mat _convertYUV420ToMat(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;
  
//   // Для YUV420 (NV21/NV12) объединяем planes и конвертируем
//   final Uint8List bytes = Uint8List.fromList([
//     ...image.planes[0].bytes, // Y plane
//     ...image.planes[1].bytes, // UV/VU plane
//   ]);
  
//   // Создаем Mat из объединенного массива байтов в формате YUV (CV_8UC1 - неверно, это YUV)
//   // Правильный способ зависит от opencv_dart FFI, но обычно это делают так:
  
//   // Создаем Mat в формате YUV и конвертируем его в BGR
//   cv.Mat yuvMat = cv.Mat.fromBytes(height * 3 ~/ 2, width, cv.CV_8UC1, bytes);
//   cv.Mat bgrMat = cv.Mat.empty();
  
//   // Указываем правильный код конвертации. COLOR_YUV2BGR_NV21 или COLOR_YUV2BGR_NV12
//   cv.cvtColor(yuvMat, bgrMat, cv.COLOR_YUV2BGR_NV21);
  
//   yuvMat.dispose(); // Очищаем временную YUV матрицу
//   return bgrMat;
// }

// cv.Mat _convertBGRA8888ToMat(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;
  
//   // Для BGRA8888 данные обычно уже в одном непрерывном массиве
//   final Uint8List bytes = image.planes[0].bytes;
  
//   // Создаем Mat из байтов (CV_8UC4 = 4 канала)
//   cv.Mat bgraMat = cv.Mat.fromBytes(height, width, cv.CV_8UC4, bytes);
//   cv.Mat bgrMat = cv.Mat.empty();
  
//   cv.cvtColor(bgraMat, bgrMat, cv.COLOR_BGRA2BGR);
  
//   bgraMat.dispose(); // Очищаем временную BGRA матрицу
//   return bgrMat;
// }

// cv.Mat _convertJPEGToMat(CameraImage image) {
//   // Для JPEG используем imdecode
//   final cv.Mat encodedBytes = cv.Mat.fromBytes(1, image.planes[0].bytes.length, cv.CV_8UC1, image.planes[0].bytes);
//   final cv.Mat decoded = cv.imdecode(encodedBytes, cv.IMREAD_COLOR);
//   encodedBytes.dispose(); // Очищаем временную Mat с закодированными байтами
//   return decoded;
// }


















// import 'package:camera/camera.dart';
// import 'package:opencv_dart/opencv_dart.dart';
// import 'dart:typed_data';

// import 'package:opencv_dart/opencv_dart.dart' as Cv2;

// List<Point2f> processLaserFrame(CameraImage image) {
//   List<Point2f> laserCenters = [];
  
//   try {
//     // Конвертируем CameraImage в Mat
//     Mat src = _cameraImageToMat(image);
    
//     // Конвертируем в HSV для лучшего выделения красного цвета
//     Mat hsv = Mat.empty();
//     Cv2.cvtColor(src, hsv, Cv2.COLOR_BGR2HSV);
    
//     // Определяем диапазоны для красного цвета в HSV
//     // Красный цвет в HSV имеет два диапазона из-за того, что он на границе hue
//     Mat mask1 = Mat.empty();
//     Mat mask2 = Mat.empty();
//     Mat redMask = Mat.empty();
    
//     // Нижний красный диапазон
//     Cv2.inRange(hsv, Scalar(0, 120, 70), Scalar(10, 255, 255), mask1);
//     // Верхний красный диапазон  
//     Cv2.inRange(hsv, Scalar(170, 120, 70), Scalar(180, 255, 255), mask2);
    
//     // Комбинируем маски
//     Cv2.bitwiseOr(mask1, mask2, redMask);
    
//     // Морфологические операции для удаления шума
//     Mat kernel = Mat.ones(5, 5, Cv2.CV_8U);
//     Cv2.morphologyEx(redMask, redMask, Cv2.MORPH_OPEN, kernel);
//     Cv2.morphologyEx(redMask, redMask, Cv2.MORPH_CLOSE, kernel);
    
//     // Находим контуры
//     List<MatOfPoint> contours = [];
//     Mat hierarchy = Mat.empty();
//     Cv2.findContours(redMask, contours, hierarchy, Cv2.RETR_EXTERNAL, Cv2.CHAIN_APPROX_SIMPLE);
    
//     // Фильтруем контуры по площади и находим центры
//     for (int i = 0; i < contours.length; i++) {
//       double area = Cv2.contourArea(contours[i]);
      
//       // Фильтр по минимальной площади (настраиваем под ваш случай)
//       if (area > 100.0) {
//         // Вычисляем моменты контура
//         Moments moments = Cv2.moments(contours[i]);
        
//         if (moments.m00 != 0) {
//           double centerX = moments.m10 / moments.m00;
//           double centerY = moments.m01 / moments.m00;
          
//           laserCenters.add(Point2f(centerX, centerY));
//         }
//       }
//     }
    
//     // Очищаем память
//     src.release();
//     hsv.release();
//     mask1.release();
//     mask2.release();
//     redMask.release();
//     kernel.release();
//     hierarchy.release();
    
//   } catch (e) {
//     print('Error in processFrame: $e');
//   }
  
//   return laserCenters;
// }

// // Вспомогательная функция для конвертации CameraImage в Mat
// Mat _cameraImageToMat(CameraImage image) {
//   try {
//     if (image.format.group == ImageFormatGroup.yuv420) {
//       return _convertYUV420ToMat(image);
//     } else if (image.format.group == ImageFormatGroup.bgra8888) {
//       return _convertBGRA8888ToMat(image);
//     } else if (image.format.group == ImageFormatGroup.jpeg) {
//       return _convertJPEGToMat(image);
//     }
//   } catch (e) {
//     print('Error converting CameraImage to Mat: $e');
//   }
  
//   return Mat.empty();
// }

// Mat _convertYUV420ToMat(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;
  
//   // Для YUV420 нам нужно преобразовать в BGR
//   Mat yuvMat = Mat.fromPtr(height * 3 ~/ 2, width, Cv2.CV_8UC1, image.planes[0].bytes);
//   Mat bgrMat = Mat.empty();
  
//   Cv2.cvtColor(yuvMat, bgrMat, Cv2.COLOR_YUV2BGR_NV21);
  
//   yuvMat.release();
//   return bgrMat;
// }

// Mat _convertBGRA8888ToMat(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;
  
//   Mat mat = Mat.fromPtr(height, width, Cv2.CV_8UC4, image.planes[0].bytes);
//   Mat bgrMat = Mat.empty();
  
//   Cv2.cvtColor(mat, bgrMat, Cv2.COLOR_BGRA2BGR);
  
//   mat.release();
//   return bgrMat;
// }

// Mat _convertJPEGToMat(CameraImage image) {
//   // Для JPEG используем imdecode
//   return Cv2.imdecode(image.planes[0].bytes, Cv2.IMREAD_COLOR);
// }

// // Класс Point2f для представления точки с координатами float
// class Point2f {
//   final double x;
//   final double y;
  
//   Point2f(this.x, this.y);
  
//   @override
//   String toString() => 'Point2f($x, $y)';
// }