import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../domain/entities/entities.dart';

/// 水印服务
class WatermarkService {
  /// 添加水印
  Uint8List addWatermark(Uint8List imageBytes, WatermarkConfig config) {
    if (config.text.isEmpty) {
      return imageBytes;
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('无法解码图片');
    }

    // 计算颜色（应用透明度）
    final alpha = ((config.opacity * 255).round() << 24);
    final colorValue = config.color.toARGB32();
    final colorWithAlpha = (alpha | (colorValue & 0x00FFFFFF)) & 0xFFFFFFFF;
    final color = img.ColorRgba8(
      (colorWithAlpha >> 16) & 0xFF,
      (colorWithAlpha >> 8) & 0xFF,
      colorWithAlpha & 0xFF,
      (colorWithAlpha >> 24) & 0xFF,
    );

    // 计算位置
    final textWidth = config.text.length * (config.fontSize * 0.6).round();
    final textHeight = config.fontSize.round();

    int x, y;
    switch (config.position) {
      case WatermarkPosition.topLeft:
        x = config.offsetX;
        y = config.offsetY;
        break;
      case WatermarkPosition.topRight:
        x = image.width - textWidth - config.offsetX;
        y = config.offsetY;
        break;
      case WatermarkPosition.bottomLeft:
        x = config.offsetX;
        y = image.height - textHeight - config.offsetY;
        break;
      case WatermarkPosition.bottomRight:
        x = image.width - textWidth - config.offsetX;
        y = image.height - textHeight - config.offsetY;
        break;
      case WatermarkPosition.center:
        x = (image.width - textWidth) ~/ 2;
        y = (image.height - textHeight) ~/ 2;
        break;
    }

    // 绘制文字
    img.drawString(
      image,
      config.text,
      font: img.arial48,
      x: x,
      y: y,
      color: color,
    );

    return Uint8List.fromList(img.encodePng(image));
  }
}
