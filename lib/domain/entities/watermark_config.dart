import 'dart:ui';

/// 水印位置枚举
enum WatermarkPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

/// 水印配置
class WatermarkConfig {
  final String text;
  final WatermarkPosition position;
  final double fontSize;
  final Color color;
  final double opacity;
  final int offsetX;
  final int offsetY;

  const WatermarkConfig({
    this.text = '',
    this.position = WatermarkPosition.bottomRight,
    this.fontSize = 24.0,
    this.color = const Color(0xFFFFFFFF),
    this.opacity = 0.8,
    this.offsetX = 20,
    this.offsetY = 20,
  });

  WatermarkConfig copyWith({
    String? text,
    WatermarkPosition? position,
    double? fontSize,
    Color? color,
    double? opacity,
    int? offsetX,
    int? offsetY,
  }) {
    return WatermarkConfig(
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }
}
