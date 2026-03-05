import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/entities.dart';
import '../../infrastructure/di.dart';
import '../../infrastructure/image/image_service.dart';
import '../../infrastructure/image/watermark_service.dart';
import '../../infrastructure/image/frame_service.dart';
import '../../infrastructure/image/export_service.dart';

/// 图片状态管理
class ImageState extends ChangeNotifier {
  final _imageService = getIt<ImageService>();
  final _watermarkService = getIt<WatermarkService>();
  final _frameService = getIt<FrameService>();
  final _exportService = getIt<ExportService>();

  // 状态
  ImageItem? _currentImage;
  Uint8List? _previewBytes;
  ExifData? _exifData;
  WatermarkConfig _watermarkConfig = const WatermarkConfig();
  FrameTemplate _selectedFrame = FrameTemplate.presets[0];
  ExportConfig _exportConfig = const ExportConfig();
  bool _isLoading = false;
  String? _error;

  // Getters
  ImageItem? get currentImage => _currentImage;
  Uint8List? get previewBytes => _previewBytes;
  ExifData? get exifData => _exifData;
  WatermarkConfig get watermarkConfig => _watermarkConfig;
  FrameTemplate get selectedFrame => _selectedFrame;
  ExportConfig get exportConfig => _exportConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasImage => _currentImage != null;

  /// 选择图片
  Future<void> pickImage() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final path = result.files.first.path;
      if (path == null) return;

      _currentImage = await _imageService.loadImage(path);
      _exifData = _imageService.readExif(_currentImage!.bytes);
      
      await _updatePreview();
    } catch (e) {
      _setError('选择图片失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新水印配置
  void updateWatermarkConfig(WatermarkConfig config) {
    _watermarkConfig = config;
    _updatePreview();
  }

  /// 更新水印文字
  void updateWatermarkText(String text) {
    _watermarkConfig = _watermarkConfig.copyWith(text: text);
    _updatePreview();
  }

  /// 更新水印位置
  void updateWatermarkPosition(WatermarkPosition position) {
    _watermarkConfig = _watermarkConfig.copyWith(position: position);
    _updatePreview();
  }

  /// 更新水印字体大小
  void updateWatermarkFontSize(double size) {
    _watermarkConfig = _watermarkConfig.copyWith(fontSize: size);
    _updatePreview();
  }

  /// 更新水印颜色
  void updateWatermarkColor(Color color) {
    _watermarkConfig = _watermarkConfig.copyWith(color: color);
    _updatePreview();
  }

  /// 更新水印透明度
  void updateWatermarkOpacity(double opacity) {
    _watermarkConfig = _watermarkConfig.copyWith(opacity: opacity);
    _updatePreview();
  }

  /// 选择相框
  void selectFrame(FrameTemplate frame) {
    _selectedFrame = frame;
    _updatePreview();
  }

  /// 更新导出配置
  void updateExportConfig(ExportConfig config) {
    _exportConfig = config;
    notifyListeners();
  }

  /// 更新导出格式
  void updateExportFormat(ExportFormat format) {
    _exportConfig = _exportConfig.copyWith(format: format);
    notifyListeners();
  }

  /// 更新导出质量
  void updateExportQuality(int quality) {
    _exportConfig = _exportConfig.copyWith(quality: quality);
    notifyListeners();
  }

  /// 导出图片
  Future<void> exportImage() async {
    if (_currentImage == null || _previewBytes == null) return;

    try {
      _setLoading(true);
      _clearError();

      await _exportService.exportImage(
        _previewBytes!,
        _currentImage!.name,
        _exportConfig,
      );
    } catch (e) {
      _setError('导出失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新预览图
  Future<void> _updatePreview() async {
    if (_currentImage == null) return;

    try {
      var bytes = _currentImage!.bytes;

      // 应用水印
      if (_watermarkConfig.text.isNotEmpty) {
        bytes = _watermarkService.addWatermark(bytes, _watermarkConfig);
      }

      // 应用相框
      if (_selectedFrame.id != 'none') {
        bytes = _frameService.applyFrame(bytes, _selectedFrame);
      }

      _previewBytes = bytes;
      notifyListeners();
    } catch (e) {
      _setError('更新预览失败: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// 清除图片
  void clearImage() {
    _currentImage = null;
    _previewBytes = null;
    _exifData = null;
    _watermarkConfig = const WatermarkConfig();
    _selectedFrame = FrameTemplate.presets[0];
    _error = null;
    notifyListeners();
  }
}
