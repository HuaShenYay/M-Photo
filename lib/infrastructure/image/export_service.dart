import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/entities.dart';

/// 导出服务
class ExportService {
  /// 导出图片
  Future<String?> exportImage(
    Uint8List imageBytes,
    String originalName,
    ExportConfig config,
  ) async {
    // 解码图片
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw Exception('无法解码图片');
    }

    // 编码图片
    Uint8List encodedBytes;
    String extension;

    if (config.format == ExportFormat.png) {
      encodedBytes = Uint8List.fromList(img.encodePng(decodedImage));
      extension = 'png';
    } else {
      encodedBytes = Uint8List.fromList(
        img.encodeJpg(decodedImage, quality: config.quality),
      );
      extension = 'jpg';
    }

    // 生成输出文件名
    final baseName = originalName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final outputName = '${baseName}_watermarked.$extension';

    // 选择保存位置
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '保存图片',
      fileName: outputName,
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    if (outputPath == null) {
      return null;
    }

    // 写入文件
    final file = File(outputPath);
    await file.writeAsBytes(encodedBytes);

    return outputPath;
  }
}
