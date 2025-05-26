import 'app.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {

  // Register DatabaseService as singleton
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  
  // Register AudioCubit
  getIt.registerFactory<AudioCubit>(() => AudioCubit());
  
  // Register RecordBloc
  getIt.registerFactory<RecordBloc>(() => RecordBloc());
}