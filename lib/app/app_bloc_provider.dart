import 'app.dart';
import 'dependency_injection.dart';

final List<BlocProvider> appProviders = [
  BlocProvider<AudioCubit>(create: (context) => getIt<AudioCubit>()),
  BlocProvider<RecordBloc>(create: (context) => getIt<RecordBloc>()),
];
