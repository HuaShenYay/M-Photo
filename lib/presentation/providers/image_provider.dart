import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/entities.dart';
import '../../infrastructure/di.dart';
import '../../infrastructure/image/image_service.dart';
import '../../infrastructure/image/watermark_service.dart';
import '../../infrastructure/image/frame_service.dart';
import '../../infrastructure/image/export_service.dart';

/// 图片状态管理 - 性能优化版
class ImageState extends ChangeNotifier {
  final _imageService = getIt<ImageService>();
  final _watermarkService = getIt<WatermarkService>();
  final _frameService = getIt<FrameService>();
  final _exportService = getIt<ExportService>();

  // 防抖定时器 - 增加到500ms
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  // 状态
  ImageItem? _currentImage;
  Uint8List? _previewBytes;
  ExifData? _exifData;
  WatermarkConfig _watermarkConfig = const WatermarkConfig();
  FrameTemplate _selectedFrame = FrameTemplate.presets[0];
  ExportConfig _exportConfig = const ExportConfig();
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  // Getters
  ImageItem? get currentImage => _currentImage;
  Uint8List? get previewBytes => _previewBytes;
  ExifData? get exifData => _exifData;
  WatermarkConfig get watermarkConfig => _watermarkConfig;
  FrameTemplate get selectedFrame => _selectedFrame;
  ExportConfig get exportConfig => _exportConfig;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  bool get hasImage => _currentImage != null;

  /// 选择图片
  Future<void> pickImage() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.path;
      if (path == null) return;

      _currentImage = await _imageService.loadImage(path);
      _exifData = await _imageService.readExif(_currentImage!.bytes);
      
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
    _debouncedUpdatePreview();
  }

  /// 选择模板
  void selectTemplate(String templateId) {
    _watermarkConfig = _watermarkConfig.copyWith(templateId: templateId);
    _debouncedUpdatePreview();
  }

  /// 切换水印启用状态
  void toggleWatermarkEnabled(bool enabled) {
    _watermarkConfig = _watermarkConfig.copyWith(enabled: enabled);
    _debouncedUpdatePreview();
  }

  /// 更新图层（用于拖拽等）
  void updateLayers(List<WatermarkLayer> layers) {
    _watermarkConfig = _watermarkConfig.copyWith(layers: layers);
    _debouncedUpdatePreview();
  }

  /// 更新单个图层位置（拖拽用）
  void updateLayerPosition(String layerId, double x, double y) {
    final currentLayers = _watermarkConfig.activeLayers;
    final newLayers = currentLayers.map((layer) {
      if (layer.id == layerId) {
        return layer.copyWith(x: x, y: y);
      }
      return layer;
    }).toList();
    
    // 如果使用的是预设模板，切换到自定义图层
    if (_watermarkConfig.layers.isEmpty) {
      _watermarkConfig = _watermarkConfig.copyWith(
        layers: newLayers,
        templateId: 'blank', // 切换到自定义模式
      );
    } else {
      _watermarkConfig = _watermarkConfig.copyWith(layers: newLayers);
    }
    _debouncedUpdatePreview();
  }

  /// 添加图层
  void addLayer(WatermarkLayer layer) {
    final newLayers = List<WatermarkLayer>.from(_watermarkConfig.layers)..add(layer);
    _watermarkConfig = _watermarkConfig.copyWith(layers: newLayers);
    _debouncedUpdatePreview();
  }

  /// 删除图层
  void removeLayer(String layerId) {
    final newLayers = _watermarkConfig.layers.where((l) => l.id != layerId).toList();
    _watermarkConfig = _watermarkConfig.copyWith(layers: newLayers);
    _debouncedUpdatePreview();
  }

  void selectFrame(FrameTemplate frame) {
    _selectedFrame = frame;
    _updatePreview();
  }

  void updateExportConfig(ExportConfig config) {
    _exportConfig = config;
    notifyListeners();
  }

  void updateExportFormat(ExportFormat format) {
    _exportConfig = _exportConfig.copyWith(format: format);
    notifyListeners();
  }

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

  /// 防抖更新预览 - 避免频繁重绘
  void _debouncedUpdatePreview() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _updatePreview();
    });
    notifyListeners();
  }

  /// 更新预览图 - 使用缩略图优化性能
  Future<void> _updatePreview() async {
    if (_currentImage == null) return;
    if (_isProcessing) return;
    
    _isProcessing = true;
    notifyListeners();

    try {
      // 预览模式：使用缩略图 + forPreview=true
      var bytes = _watermarkService.addWatermark(
        _currentImage!.bytes, 
        _watermarkConfig,
        exifData: _exifData,
        forPreview: true,
      );

      // 应用相框
      if (_selectedFrame.id != 'none') {
        bytes = _frameService.applyFrame(bytes, _selectedFrame);
      }

      _previewBytes = bytes;
      _error = null;
    } catch (e) {
      _setError('更新预览失败: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// 导出时生成最终图片（不使用缩略图）
  Future<Uint8List?> generateFinalImage() async {
    if (_currentImage == null) return null;
    
    try {
      // 导出模式：使用原图
      var bytes = _watermarkService.addWatermark(
        _currentImage!.bytes, 
        _watermarkConfig,
        exifData: _exifData,
        forPreview: false,
      );

      // 应用相框
      if (_selectedFrame.id != 'none') {
        bytes = _frameService.applyFrame(bytes, _selectedFrame);
      }

      return bytes;
    } catch (e) {
      _setError('生成图片失败: $e');
      return null;
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

  void clearImage() {
    _debounceTimer?.cancel();
    _currentImage = null;
    _previewBytes = null;
    _exifData = null;
    _watermarkConfig = const WatermarkConfig();
    _selectedFrame = FrameTemplate.presets[0];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
