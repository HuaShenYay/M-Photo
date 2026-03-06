import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import '../../domain/entities/entities.dart';

/// 水印服务 - 支持多图层合成
class WatermarkService {
  /// 添加水印 - 支持多图层
  Uint8List addWatermark(Uint8List imageBytes, WatermarkConfig config, {ExifData? exifData, bool forPreview = false}) {
    // 如果未启用或没有图层，直接返回原图
    if (!config.enabled || config.activeLayers.isEmpty) {
      return imageBytes;
    }

    // 预览时缩小图片以提高性能
    final image = forPreview ? _decodeAndResize(imageBytes, 800) : img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('无法解码图片');
    }

    // 遍历所有图层并绘制
    for (final layer in config.activeLayers) {
      _drawLayer(image, layer, exifData);
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  /// 解码并可选缩放图片
  img.Image? _decodeAndResize(Uint8List bytes, int maxDimension) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    
    // 如果图片已经小于目标尺寸，不缩放
    if (decoded.width <= maxDimension && decoded.height <= maxDimension) {
      return decoded;
    }
    
    // 计算缩放比例
    final scale = maxDimension / (decoded.width > decoded.height ? decoded.width : decoded.height);
    return img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
    );
  }

  /// 绘制单个图层
  void _drawLayer(img.Image image, WatermarkLayer layer, ExifData? exifData) {
    // 计算实际像素坐标
    final x = (layer.x * image.width).round();
    final y = (layer.y * image.height).round();
    
    switch (layer.type) {
      case WatermarkLayerType.text:
        _drawTextLayer(image, layer, x, y);
        break;
      case WatermarkLayerType.image:
        _drawImageLayer(image, layer, x, y);
        break;
      case WatermarkLayerType.exif:
        _drawExifLayer(image, layer, x, y, exifData);
        break;
    }
  }

  /// 绘制文字图层
  void _drawTextLayer(img.Image image, WatermarkLayer layer, int x, int y) {
    if (layer.text == null || layer.text!.isEmpty) return;
    
    final color = _toImageColor(layer.color, layer.opacity);
    img.drawString(
      image,
      layer.text!,
      font: img.arial48,
      x: x,
      y: y,
      color: color,
    );
  }

  /// 绘制图片图层
  void _drawImageLayer(img.Image image, WatermarkLayer layer, int x, int y) {
    if (layer.imageBytes == null) return;
    
    final overlay = img.decodeImage(layer.imageBytes!);
    if (overlay == null) return;
    
    // 应用透明度
    if (layer.opacity < 1.0) {
      _applyOpacity(overlay, layer.opacity);
    }
    
    // 调整图片大小
    final resized = img.copyResize(overlay, width: layer.width.round());
    
    // 叠加到主图
    img.compositeImage(image, resized, dstX: x, dstY: y);
  }

  /// 绘制EXIF图层
  void _drawExifLayer(img.Image image, WatermarkLayer layer, int x, int y, ExifData? exifData) {
    if (exifData == null) return;
    
    final lines = <String>[];
    
    if (layer.showExifMake && exifData.cameraMake != null) {
      lines.add(exifData.cameraMake!);
    }
    if (layer.showExifModel && exifData.cameraModel != null) {
      lines.add(exifData.cameraModel!);
    }
    if (layer.showExifAperture && exifData.aperture != null) {
      lines.add(exifData.aperture!);
    }
    if (layer.showExifShutter && exifData.shutterSpeed != null) {
      lines.add(exifData.shutterSpeed!);
    }
    if (layer.showExifIso && exifData.iso != null) {
      lines.add(exifData.iso!);
    }
    if (layer.showExifDate && exifData.dateTime != null) {
      lines.add(exifData.dateTime!);
    }
    
    if (lines.isEmpty) return;
    
    final text = lines.join('\n');
    final color = _toImageColor(layer.color, layer.opacity);
    
    img.drawString(
      image,
      text,
      font: img.arial48,
      x: x,
      y: y,
      color: color,
    );
  }

  /// 将Flutter Color转换为image包的颜色
  img.Color _toImageColor(ui.Color color, double opacity) {
    final alpha = ((opacity * color.a / 255) * 255).round();
    return img.ColorRgba8(
      color.r.round(),
      color.g.round(),
      color.b.round(),
      alpha,
    );
  }

  /// 应用透明度到整个图片
  void _applyOpacity(img.Image image, double opacity) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final a = (pixel.a * opacity).round();
        image.setPixel(x, y, img.ColorRgba8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), a));
      }
    }
  }
}
