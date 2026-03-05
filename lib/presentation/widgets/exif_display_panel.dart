import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// EXIF信息展示面板
class ExifDisplayPanel extends StatelessWidget {
  final ExifData exifData;

  const ExifDisplayPanel({
    super.key,
    required this.exifData,
  });

  @override
  Widget build(BuildContext context) {
    if (!exifData.hasData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                '该图片无EXIF信息',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt, size: 20),
                const SizedBox(width: 8),
                Text(
                  '图片信息',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (exifData.cameraInfo != '未知')
              _buildInfoRow(context, Icons.photo_camera, '相机', exifData.cameraInfo),
            if (exifData.aperture != null)
              _buildInfoRow(context, Icons.camera, '光圈', exifData.aperture!),
            if (exifData.shutterSpeed != null)
              _buildInfoRow(context, Icons.shutter_speed, '快门', exifData.shutterSpeed!),
            if (exifData.iso != null)
              _buildInfoRow(context, Icons.iso, 'ISO', exifData.iso!),
            if (exifData.dateTime != null)
              _buildInfoRow(context, Icons.calendar_today, '日期', exifData.dateTime!),
            if (exifData.width != null && exifData.height != null)
              _buildInfoRow(
                context,
                Icons.aspect_ratio,
                '尺寸',
                '${exifData.width} x ${exifData.height}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
