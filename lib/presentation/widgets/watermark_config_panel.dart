import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/entities.dart';

/// 水印配置面板 - 模板选择模式
class WatermarkConfigPanel extends StatelessWidget {
  final WatermarkConfig config;
  final Function(String templateId) onTemplateChanged;
  final Function(bool enabled) onEnabledChanged;
  final Function(WatermarkLayer)? onAddLayer;
  final VoidCallback? onImportImage;

  const WatermarkConfigPanel({
    super.key,
    required this.config,
    required this.onTemplateChanged,
    required this.onEnabledChanged,
    this.onAddLayer,
    this.onImportImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和开关
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '水印模板',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: config.enabled,
                  onChanged: onEnabledChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 模板选择
            if (config.enabled) ...[
              Text(
                '选择模板',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              _buildTemplateSelector(context),
              const SizedBox(height: 16),
              
              // 模板描述
              _buildTemplateDescription(context),
              const SizedBox(height: 16),
              
              // 自定义操作按钮
              _buildCustomActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(BuildContext context) {
    final templates = WatermarkTemplates.presets;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: templates.map((template) {
        final isSelected = config.templateId == template.id;
        return ChoiceChip(
          label: Text(template.name),
          selected: isSelected,
          onSelected: (_) => onTemplateChanged(template.id),
        );
      }).toList(),
    );
  }

  Widget _buildTemplateDescription(BuildContext context) {
    final template = WatermarkTemplates.getById(config.templateId);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '图层数量: ${template.layers.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // 添加文字图层按钮
            ActionChip(
              avatar: const Icon(Icons.text_fields, size: 18),
              label: const Text('添加文字'),
              onPressed: () {
                if (onAddLayer != null) {
                  final newLayer = WatermarkLayer(
                    type: WatermarkLayerType.text,
                    id: 'text_${DateTime.now().millisecondsSinceEpoch}',
                    text: '新文字',
                    x: 0.5,
                    y: 0.5,
                    fontSize: 24,
                    color: const Color(0xFFFFFFFF),
                    opacity: 0.8,
                  );
                  onAddLayer!(newLayer);
                }
              },
            ),
            // 导入图片按钮
            ActionChip(
              avatar: const Icon(Icons.image, size: 18),
              label: const Text('导入图片'),
              onPressed: onImportImage,
            ),
            // 添加EXIF图层按钮
            ActionChip(
              avatar: const Icon(Icons.info_outline, size: 18),
              label: const Text('添加EXIF'),
              onPressed: () {
                if (onAddLayer != null) {
                  final newLayer = WatermarkLayer(
                    type: WatermarkLayerType.exif,
                    id: 'exif_${DateTime.now().millisecondsSinceEpoch}',
                    x: 0.5,
                    y: 0.8,
                    fontSize: 14,
                    color: const Color(0xFFFFFFFF),
                    opacity: 0.9,
                    showExifModel: true,
                    showExifAperture: true,
                    showExifIso: true,
                  );
                  onAddLayer!(newLayer);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '提示：拖拽预览图中的水印可调整位置',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
