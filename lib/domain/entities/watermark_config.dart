import 'dart:typed_data';
import 'dart:ui';

/// 水印图层类型
enum WatermarkLayerType {
  text,      // 文字图层
  image,     // 图片图层
  exif,      // EXIF信息图层
}

/// 单个水印图层配置
class WatermarkLayer {
  final WatermarkLayerType type;
  final String id;              // 图层唯一ID
  final String? text;           // 文字内容(type=text)
  final Uint8List? imageBytes; // 图片数据(type=image)
  final double x;              // X坐标 (相对比例 0.0-1.0)
  final double y;              // Y坐标 (相对比例 0.0-1.0)
  final double width;           // 宽度(像素) - 图片图层用
  final double height;          // 高度(像素) - 图片图层用
  final double fontSize;        // 字体大小(type=text/exif)
  final Color color;            // 文字颜色
  final double opacity;         // 透明度 0.0-1.0
  final bool showExifMake;      // 显示相机厂商
  final bool showExifModel;     // 显示相机型号
  final bool showExifAperture;  // 显示光圈
  final bool showExifShutter;   // 显示快门
  final bool showExifIso;       // 显示ISO
  final bool showExifDate;      // 显示日期

  const WatermarkLayer({
    required this.type,
    required this.id,
    this.text,
    this.imageBytes,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 100.0,
    this.height = 100.0,
    this.fontSize = 16.0,
    this.color = const Color(0xFFFFFFFF),
    this.opacity = 1.0,
    this.showExifMake = true,
    this.showExifModel = true,
    this.showExifAperture = false,
    this.showExifShutter = false,
    this.showExifIso = false,
    this.showExifDate = false,
  });

  WatermarkLayer copyWith({
    WatermarkLayerType? type,
    String? id,
    String? text,
    Uint8List? imageBytes,
    double? x,
    double? y,
    double? width,
    double? height,
    double? fontSize,
    Color? color,
    double? opacity,
    bool? showExifMake,
    bool? showExifModel,
    bool? showExifAperture,
    bool? showExifShutter,
    bool? showExifIso,
    bool? showExifDate,
  }) {
    return WatermarkLayer(
      type: type ?? this.type,
      id: id ?? this.id,
      text: text ?? this.text,
      imageBytes: imageBytes ?? this.imageBytes,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      showExifMake: showExifMake ?? this.showExifMake,
      showExifModel: showExifModel ?? this.showExifModel,
      showExifAperture: showExifAperture ?? this.showExifAperture,
      showExifShutter: showExifShutter ?? this.showExifShutter,
      showExifIso: showExifIso ?? this.showExifIso,
      showExifDate: showExifDate ?? this.showExifDate,
    );
  }
}

/// 水印模板
class WatermarkTemplate {
  final String id;
  final String name;
  final String description;
  final List<WatermarkLayer> layers;

  const WatermarkTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.layers,
  });
}

/// 预设模板集合
class WatermarkTemplates {
  static List<WatermarkTemplate> get presets => [
    // 模板1: 简约右下角
    WatermarkTemplate(
      id: 'simple_bottom_right',
      name: '简约右下',
      description: '简洁的右下角信息显示',
      layers: [
        WatermarkLayer(
          type: WatermarkLayerType.text,
          id: 'text_1',
          text: '© 我的作品',
          x: 0.85,
          y: 0.90,
          fontSize: 18,
          color: const Color(0xFFFFFFFF),
          opacity: 0.8,
        ),
      ],
    ),
    // 模板2: 摄影信息左下
    WatermarkTemplate(
      id: 'photo_info_left',
      name: '摄影信息',
      description: '显示完整EXIF信息',
      layers: [
        WatermarkLayer(
          type: WatermarkLayerType.exif,
          id: 'exif_1',
          x: 0.02,
          y: 0.85,
          fontSize: 14,
          color: const Color(0xFFFFFFFF),
          opacity: 0.9,
          showExifMake: true,
          showExifModel: true,
          showExifAperture: true,
          showExifShutter: true,
          showExifIso: true,
          showExifDate: true,
        ),
      ],
    ),
    // 模板3: 中央文字
    WatermarkTemplate(
      id: 'center_text',
      name: '中央水印',
      description: '大面积中央文字',
      layers: [
        WatermarkLayer(
          type: WatermarkLayerType.text,
          id: 'text_1',
          text: 'SAMPLE',
          x: 0.35,
          y: 0.45,
          fontSize: 48,
          color: const Color(0xFFFFFFFF),
          opacity: 0.3,
        ),
      ],
    ),
    // 模板4: 多行信息
    WatermarkTemplate(
      id: 'multi_info',
      name: '多行信息',
      description: '包含文字和EXIF信息',
      layers: [
        WatermarkLayer(
          type: WatermarkLayerType.text,
          id: 'text_1',
          text: '© 摄影师',
          x: 0.02,
          y: 0.90,
          fontSize: 20,
          color: const Color(0xFFFFFFFF),
          opacity: 0.85,
        ),
        WatermarkLayer(
          type: WatermarkLayerType.exif,
          id: 'exif_1',
          x: 0.02,
          y: 0.95,
          fontSize: 12,
          color: const Color(0xFFCCCCCC),
          opacity: 0.7,
          showExifModel: true,
          showExifAperture: true,
          showExifIso: true,
        ),
      ],
    ),
    // 模板5: 自定义空模板
    WatermarkTemplate(
      id: 'blank',
      name: '自定义',
      description: '空白模板，自由添加图层',
      layers: [],
    ),
  ];

  /// 根据ID获取模板
  static WatermarkTemplate getById(String id) {
    return presets.firstWhere(
      (t) => t.id == id,
      orElse: () => presets.first,
    );
  }
}

/// 水印配置
class WatermarkConfig {
  final String templateId;           // 当前模板ID
  final List<WatermarkLayer> layers; // 自定义图层
  final bool enabled;                // 是否启用水印

  const WatermarkConfig({
    this.templateId = 'simple_bottom_right',
    this.layers = const [],
    this.enabled = true,
  });

  WatermarkConfig copyWith({
    String? templateId,
    List<WatermarkLayer>? layers,
    bool? enabled,
  }) {
    return WatermarkConfig(
      templateId: templateId ?? this.templateId,
      layers: layers ?? this.layers,
      enabled: enabled ?? this.enabled,
    );
  }

  /// 获取当前使用的图层列表
  List<WatermarkLayer> get activeLayers {
    if (layers.isNotEmpty) {
      return layers;
    }
    // 使用预设模板
    return WatermarkTemplates.getById(templateId).layers;
  }
}
