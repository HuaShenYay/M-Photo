import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// 相框选择器
class FrameSelector extends StatelessWidget {
  final FrameTemplate selectedFrame;
  final ValueChanged<FrameTemplate> onFrameSelected;

  const FrameSelector({
    super.key,
    required this.selectedFrame,
    required this.onFrameSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '相框',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: FrameTemplate.presets.length,
              itemBuilder: (context, index) {
                final frame = FrameTemplate.presets[index];
                final isSelected = frame.id == selectedFrame.id;

                return InkWell(
                  onTap: () => onFrameSelected(frame),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getFrameIcon(frame.id),
                            size: 32,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            frame.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFrameIcon(String id) {
    switch (id) {
      case 'none':
        return Icons.crop_free;
      case 'simple':
        return Icons.crop_square;
      case 'classic':
        return Icons.photo;
      case 'polaroid':
        return Icons.filter_frames;
      default:
        return Icons.crop_free;
    }
  }
}
