import 'dart:typed_data';

/// 相框模板
class FrameTemplate {
  final String id;
  final String name;
  final Uint8List? bytes;

  const FrameTemplate({
    required this.id,
    required this.name,
    this.bytes,
  });

  static const List<FrameTemplate> presets = [
    FrameTemplate(id: 'none', name: '无相框'),
    FrameTemplate(id: 'simple', name: '简约边框'),
    FrameTemplate(id: 'classic', name: '经典边框'),
    FrameTemplate(id: 'polaroid', name: '宝丽来'),
  ];
}
