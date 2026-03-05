import 'package:get_it/get_it.dart';
import '../infrastructure/image/image_services.dart';

final getIt = GetIt.instance;

/// 初始化依赖注入
void setupDependencies() {
  // Services
  getIt.registerLazySingleton<ImageService>(() => ImageService());
  getIt.registerLazySingleton<WatermarkService>(() => WatermarkService());
  getIt.registerLazySingleton<FrameService>(() => FrameService());
  getIt.registerLazySingleton<ExportService>(() => ExportService());
}
