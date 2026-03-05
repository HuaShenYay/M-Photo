import 'dart:io';
import 'dart:typed_data';
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

    // 验证尺寸
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
  ExifData readExif(Uint8List bytes) {
    try {
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return const ExifData();
      }

      return ExifData(
        width: decodedImage.width,
        height: decodedImage.height,
      );
    } catch (e) {
      return const ExifData();
    }
  }
}
