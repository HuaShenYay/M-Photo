import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// 图片预览组件 - 支持水印拖拽
class ImagePreviewWidget extends StatefulWidget {
  final Uint8List imageBytes;
  final WatermarkConfig? watermarkConfig;
  final Function(String layerId, double x, double y)? onLayerDragged;

  const ImagePreviewWidget({
    super.key,
    required this.imageBytes,
    this.watermarkConfig,
    this.onLayerDragged,
  });

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateImageSize());
  }

  void _updateImageSize() {
    final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _imageSize = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // 图片
                  InteractiveViewer(
                    key: _imageKey,
                    minScale: 0.5,
                    maxScale: 4.0,
                    onInteractionEnd: (_) => _updateImageSize(),
                    child: Image.memory(
                      widget.imageBytes,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                  // 水印图层拖拽层
                  if (widget.watermarkConfig?.enabled == true && 
                      _imageSize != null)
                    _buildWatermarkOverlays(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWatermarkOverlays() {
    final layers = widget.watermarkConfig?.activeLayers ?? [];
    if (layers.isEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: layers.map((layer) {
              return _buildDraggableLayer(layer, constraints);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDraggableLayer(WatermarkLayer layer, BoxConstraints constraints) {
    // 计算实际像素位置
    final x = layer.x * constraints.maxWidth;
    final y = layer.y * constraints.maxHeight;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (widget.onLayerDragged != null) {
            // 计算新的相对位置
            final newX = (layer.x + details.delta.dx / constraints.maxWidth).clamp(0.0, 1.0);
            final newY = (layer.y + details.delta.dy / constraints.maxHeight).clamp(0.0, 1.0);
            widget.onLayerDragged!(layer.id, newX, newY);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _buildLayerContent(layer),
        ),
      ),
    );
  }

  Widget _buildLayerContent(WatermarkLayer layer) {
    switch (layer.type) {
      case WatermarkLayerType.text:
        return Text(
          layer.text ?? '',
          style: TextStyle(
            color: layer.color.withValues(alpha: layer.opacity),
            fontSize: layer.fontSize * 0.5, // 缩放显示
          ),
        );
      case WatermarkLayerType.image:
        if (layer.imageBytes != null) {
          return Image.memory(
            layer.imageBytes!,
            width: layer.width * 0.3,
            height: layer.height * 0.3,
          );
        }
        return const Icon(Icons.image, size: 24);
      case WatermarkLayerType.exif:
        return Container(
          padding: const EdgeInsets.all(4),
          color: Colors.black54,
          child: Text(
            'EXIF',
            style: TextStyle(
              color: layer.color.withValues(alpha: layer.opacity),
              fontSize: 10,
            ),
          ),
        );
    }
  }
}
