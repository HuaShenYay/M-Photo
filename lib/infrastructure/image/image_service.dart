import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart' as exif_lib;
import 'package:image/image.dart' as img;
import '../../domain/entities/entities.dart';

/// 图片处理服务
class ImageService {
  static const int maxDimension = 8192;

  /// 加载图片
  Future<ImageItem> loadImage(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('无法解码图片: $path');
    }

    if (image.width > maxDimension || image.height > maxDimension) {
      throw Exception('图片尺寸超过限制: ${image.width}x${image.height} (最大: $maxDimension)');
    }

    return ImageItem(
      path: path,
      name: path.split(Platform.pathSeparator).last,
      bytes: bytes,
      width: image.width,
      height: image.height,
    );
  }

  /// 读取EXIF数据
  Future<ExifData> readExif(Uint8List bytes) async {
    try {
      // 先解码图片获取尺寸
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return const ExifData();
      }

      // 使用exif包读取EXIF数据
      final tags = await exif_lib.readExifFromBytes(bytes);
      if (tags.isEmpty) {
        return ExifData(
          width: decodedImage.width,
          height: decodedImage.height,
        );
      }

      // 提取EXIF字段
      String? getTagValue(String key) {
        final tag = tags[key];
        if (tag == null) return null;
        final value = tag.printable;
        return value.isEmpty ? null : value;
      }

      // 处理光圈值
      String? formatAperture(String? value) {
        if (value == null) return null;
        try {
          final numValue = double.tryParse(value);
          if (numValue != null) {
            return 'f/${numValue.toStringAsFixed(1)}';
          }
        } catch (_) {}
        return 'f/$value';
      }

      // 处理快门速度
      String? formatShutterSpeed(String? value) {
        if (value == null) return null;
        return '${value}s';
      }

      // 处理ISO
      String? formatIso(String? value) {
        if (value == null) return null;
        return 'ISO $value';
      }

      // 提取日期时间
      String? getDateTime() {
        final dateOriginal = getTagValue('EXIF DateTimeOriginal');
        if (dateOriginal != null) {
          try {
            final parts = dateOriginal.split(' ');
            if (parts.length == 2) {
              final dateParts = parts[0].split(':');
              final timeParts = parts[1].split(':');
              if (dateParts.length == 3 && timeParts.length >= 2) {
                return '${dateParts[0]}-${dateParts[1]}-${dateParts[2]} ${timeParts[0]}:${timeParts[1]}';
              }
            }
          } catch (_) {}
          return dateOriginal;
        }
        return getTagValue('EXIF DateTime');
      }

      return ExifData(
        cameraMake: getTagValue('Image Make'),
        cameraModel: getTagValue('Image Model'),
        aperture: formatAperture(getTagValue('EXIF FNumber')?.replaceFirst('f/', '')),
        shutterSpeed: formatShutterSpeed(getTagValue('EXIF ExposureTime')),
        iso: formatIso(getTagValue('EXIF ISOSpeedRatings')),
        dateTime: getDateTime(),
        width: decodedImage.width,
        height: decodedImage.height,
      );
    } catch (e) {
      return const ExifData();
    }
  }
}
