import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../domain/entities/entities.dart';

/// 相框服务
class FrameService {
  /// 叠加相框
  Uint8List applyFrame(Uint8List imageBytes, FrameTemplate frame) {
    if (frame.id == 'none' || frame.bytes == null) {
      return imageBytes;
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('无法解码图片');
    }

    final frameImage = img.decodeImage(frame.bytes!);
    if (frameImage == null) {
      throw Exception('无法解码相框');
    }

    // 缩放相框以匹配图片尺寸
    final scaledFrame = img.copyResize(
      frameImage,
      width: image.width,
      height: image.height,
    );

    // 叠加相框
    img.compositeImage(image, scaledFrame);

    return Uint8List.fromList(img.encodePng(image));
  }
}
