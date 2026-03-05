import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// 水印配置面板
class WatermarkConfigPanel extends StatelessWidget {
  final WatermarkConfig config;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<WatermarkPosition> onPositionChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onOpacityChanged;

  const WatermarkConfigPanel({
    super.key,
    required this.config,
    required this.onTextChanged,
    required this.onPositionChanged,
    required this.onFontSizeChanged,
    required this.onColorChanged,
    required this.onOpacityChanged,
  });

  static const List<Color> presetColors = [
    Colors.white,
    Colors.black,
    Color(0xFF6750A4),
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文字水印',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // 文字输入
            TextField(
              decoration: const InputDecoration(
                labelText: '水印文字',
                hintText: '输入水印内容',
                border: OutlineInputBorder(),
              ),
              onChanged: onTextChanged,
            ),
            const SizedBox(height: 16),
            // 位置选择
            Text(
              '位置',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WatermarkPosition.values.map((pos) {
                final isSelected = config.position == pos;
                return ChoiceChip(
                  label: Text(_getPositionLabel(pos)),
                  selected: isSelected,
                  onSelected: (_) => onPositionChanged(pos),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 字体大小
            Row(
              children: [
                const Text('字体大小'),
                Expanded(
                  child: Slider(
                    value: config.fontSize,
                    min: 12,
                    max: 72,
                    divisions: 60,
                    label: config.fontSize.round().toString(),
                    onChanged: onFontSizeChanged,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('${config.fontSize.round()}'),
                ),
              ],
            ),
            // 透明度
            Row(
              children: [
                const Text('透明度'),
                Expanded(
                  child: Slider(
                    value: config.opacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(config.opacity * 100).round()}%',
                    onChanged: onOpacityChanged,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('${(config.opacity * 100).round()}%'),
                ),
              ],
            ),
            // 颜色选择
            Text(
              '颜色',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: presetColors.map((color) {
                final isSelected = config.color.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => onColorChanged(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getPositionLabel(WatermarkPosition position) {
    switch (position) {
      case WatermarkPosition.topLeft:
        return '左上';
      case WatermarkPosition.topRight:
        return '右上';
      case WatermarkPosition.bottomLeft:
        return '左下';
      case WatermarkPosition.bottomRight:
        return '右下';
      case WatermarkPosition.center:
        return '居中';
    }
  }
}
