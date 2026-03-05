/// 导出格式
enum ExportFormat {
  png,
  jpeg,
}

/// 导出配置
class ExportConfig {
  final ExportFormat format;
  final int quality; // 1-100 for JPEG

  const ExportConfig({
    this.format = ExportFormat.png,
    this.quality = 90,
  });

  ExportConfig copyWith({
    ExportFormat? format,
    int? quality,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      quality: quality ?? this.quality,
    );
  }
}
