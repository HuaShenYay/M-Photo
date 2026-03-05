import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/entities.dart';
import '../providers/image_provider.dart';

/// 导出设置对话框
class ExportSettingsDialog extends StatelessWidget {
  const ExportSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageState>(
      builder: (context, state, _) {
        final config = state.exportConfig;

        return AlertDialog(
          title: const Text('导出设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 格式选择
              Text(
                '导出格式',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ExportFormat>(
                segments: const [
                  ButtonSegment(
                    value: ExportFormat.png,
                    label: Text('PNG'),
                    icon: Icon(Icons.image),
                  ),
                  ButtonSegment(
                    value: ExportFormat.jpeg,
                    label: Text('JPEG'),
                    icon: Icon(Icons.photo),
                  ),
                ],
                selected: {config.format},
                onSelectionChanged: (selection) {
                  state.updateExportFormat(selection.first);
                },
              ),
              // 质量滑块 (仅JPEG)
              if (config.format == ExportFormat.jpeg) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('质量'),
                    Expanded(
                      child: Slider(
                        value: config.quality.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 9,
                        label: '${config.quality}%',
                        onChanged: (value) {
                          state.updateExportQuality(value.round());
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text('${config.quality}%'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // 文件名预览
              if (state.currentImage != null)
                Text(
                  '输出文件: ${state.currentImage!.name.replaceAll(RegExp(r'\\.[^.]+$'), '')}_watermarked.${config.format.name}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                state.exportImage();
              },
              child: const Text('导出'),
            ),
          ],
        );
      },
    );
  }
}
