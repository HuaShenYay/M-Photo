import 'dart:typed_data';

/// 图片实体
class ImageItem {
  final String path;
  final String name;
  final Uint8List bytes;
  final int width;
  final int height;

  const ImageItem({
    required this.path,
    required this.name,
    required this.bytes,
    required this.width,
    required this.height,
  });
}
