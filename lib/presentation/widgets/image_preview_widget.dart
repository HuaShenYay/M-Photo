import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 图片预览组件
class ImagePreviewWidget extends StatelessWidget {
  final Uint8List imageBytes;

  const ImagePreviewWidget({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
