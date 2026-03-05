import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/watermark_config_panel.dart';
import '../widgets/frame_selector.dart';
import '../widgets/exif_display_panel.dart';
import '../widgets/export_settings_dialog.dart';

/// 主页面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M的相框'),
        actions: [
          Consumer<ImageState>(
            builder: (context, state, _) {
              if (!state.hasImage) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '清除图片',
                    onPressed: state.clearImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_alt),
                    tooltip: '导出图片',
                    onPressed: () => _showExportDialog(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ImageState>(
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!state.hasImage) {
            return _buildEmptyState(context);
          }

          return _buildEditor(context, state);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '点击下方按钮选择图片',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '支持 JPG / PNG / WebP',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<ImageState>().pickImage(),
            icon: const Icon(Icons.folder_open),
            label: const Text('选择图片'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, ImageState state) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ImagePreviewWidget(
            imageBytes: state.previewBytes ?? state.currentImage!.bytes,
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WatermarkConfigPanel(
                  config: state.watermarkConfig,
                  onTextChanged: state.updateWatermarkText,
                  onPositionChanged: state.updateWatermarkPosition,
                  onFontSizeChanged: state.updateWatermarkFontSize,
                  onColorChanged: state.updateWatermarkColor,
                  onOpacityChanged: state.updateWatermarkOpacity,
                ),
                const SizedBox(height: 16),
                FrameSelector(
                  selectedFrame: state.selectedFrame,
                  onFrameSelected: state.selectFrame,
                ),
                const SizedBox(height: 16),
                if (state.exifData != null)
                  ExifDisplayPanel(exifData: state.exifData!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ExportSettingsDialog(),
    );
  }
}
