import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../domain/entities/entities.dart';

/// 相框服务
class FrameService {
  /// 叠加相框
  Uint8List applyFrame(Uint8List imageBytes, FrameTemplate frame) {
    if (frame.id == 'none') {
      return imageBytes;
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('无法解码图片');
    }

    switch (frame.id) {
      case 'simple':
        _drawSimpleFrame(image);
        break;
      case 'classic':
        _drawClassicFrame(image);
        break;
      case 'polaroid':
        _drawPolaroidFrame(image);
        break;
      default:
        break;
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  /// 简约边框
  void _drawSimpleFrame(img.Image image) {
    final borderSize = (image.width * 0.02).round().clamp(5, 20);
    img.fillRect(image, x1: 0, y1: 0, x2: image.width - 1, y2: image.height - 1,
        color: img.ColorRgba8(255, 255, 255, 255));
    img.fillRect(image, x1: borderSize, y1: borderSize, 
        x2: image.width - borderSize - 1, y2: image.height - borderSize - 1,
        color: img.ColorRgba8(0, 0, 0, 255));
  }

  /// 经典边框
  void _drawClassicFrame(img.Image image) {
    final outer = (image.width * 0.03).round().clamp(10, 30);
    final inner = (image.width * 0.015).round().clamp(5, 15);
    img.fillRect(image, x1: 0, y1: 0, x2: image.width - 1, y2: image.height - 1,
        color: img.ColorRgba8(0, 0, 0, 255));
    img.fillRect(image, x1: outer, y1: outer, x2: image.width - outer - 1, y2: image.height - outer - 1,
        color: img.ColorRgba8(255, 255, 255, 255));
    img.fillRect(image, x1: outer + inner, y1: outer + inner, 
        x2: image.width - outer - inner - 1, y2: image.height - outer - inner - 1,
        color: img.ColorRgba8(0, 0, 0, 255));
  }

  /// 宝丽来风格
  void _drawPolaroidFrame(img.Image image) {
    final margin = (image.width * 0.05).round().clamp(10, 40);
    img.fillRect(image, x1: 0, y1: 0, x2: image.width - 1, y2: image.height - 1,
        color: img.ColorRgba8(255, 255, 255, 255));
    img.fillRect(image, x1: margin, y1: margin, 
        x2: image.width - margin - 1, y2: image.height - margin - 1,
        color: img.ColorRgba8(0, 0, 0, 255));
  }
}
