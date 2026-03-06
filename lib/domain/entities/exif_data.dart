/// EXIF数据
class ExifData {
  final String? cameraMake;
  final String? cameraModel;
  final String? aperture;
  final String? shutterSpeed;
  final String? iso;
  final String? dateTime;
  final int? width;
  final int? height;

  const ExifData({
    this.cameraMake,
    this.cameraModel,
    this.aperture,
    this.shutterSpeed,
    this.iso,
    this.dateTime,
    this.width,
    this.height,
  });

  bool get hasData =>
      cameraMake != null ||
      cameraModel != null ||
      aperture != null ||
      shutterSpeed != null ||
      iso != null ||
      dateTime != null ||
      width != null ||
      height != null;

  String get cameraInfo {
    if (cameraMake != null && cameraModel != null) {
      return '$cameraMake $cameraModel';
    }
    return cameraModel ?? cameraMake ?? '未知';
  }
}
