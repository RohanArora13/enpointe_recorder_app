import 'dart:async';
import 'dart:io';

import 'package:audio_app/app/app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  AudioCubit() : super(AudioInitial());

  static const amplitudeCaptureRateInMilliSeconds = 100;

  static const double decibleLimit = -30;

  final AudioRecorder _audioRecorder = AudioRecorder();

  Future<bool> checkMicPermission() async {
    // Request permissions - try multiple permission types to handle different Android versions
    List<Permission> permissionsToRequest = [Permission.microphone];

    // Add storage-related permissions for different Android versions
    if (Platform.isAndroid) {
      // Try both old and new permission types
      permissionsToRequest.addAll([
        Permission.storage,
        Permission.manageExternalStorage,
      ]);
    }

    Map<Permission, PermissionStatus> permissions = {};

    // Request permissions one by one to avoid issues
    for (Permission permission in permissionsToRequest) {
      try {
        final status = await permission.request();
        permissions[permission] = status;
      } catch (e) {
        debugPrint('Error requesting permission $permission: $e');
        // Continue with other permissions
      }
    }

    // Check if microphone permission is granted (minimum requirement)
    return permissions[Permission.microphone]?.isGranted ?? false;
  }

  void startRecording() async {
    if (await checkMicPermission()) {
      try {
        // Use external storage app-specific directory: /storage/emulated/0/Android/data/package/files
        Directory? externalDir = await getExternalStorageDirectory();

        externalDir ??= await getApplicationDocumentsDirectory();

        Directory recordingsDir = Directory('${externalDir.path}/recordings');

        if (!await recordingsDir.exists()) {
          await recordingsDir.create(recursive: true);
          debugPrint('Created recordings directory: ${recordingsDir.path}');
        }

        final filepath =
            '${recordingsDir.path}/${DateTime.now().millisecondsSinceEpoch}${Constants.fileExtention}';
        debugPrint('Recording to: $filepath');

        final config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: filepath);
        emit(RecordOn());
      } catch (e) {
        debugPrint('Error starting recording: $e');
        emit(AudioInitial());
      }
    } else {
      debugPrint('Microphone permission not granted:');
      emit(AudioInitial());
    }
  }

  void stopRecording(BuildContext context) async {
    String? path = await _audioRecorder.stop();
    emit(RecordStopped());

    debugPrint('Output path $path');
    
    // Add SaveRecordingEvent if path is not null
    if (path != null) {
      // ignore: use_build_context_synchronously
      final recordBloc = BlocProvider.of<RecordBloc>(context);
      recordBloc.add(SaveRecordingEvent(filePath: path));
    }
  }

  Future<Amplitude> getAmplitude() async {
    final amplitude = await _audioRecorder.getAmplitude();
    return amplitude;
  }

  Stream<double> aplitudeStream() async* {
    while (true) {
      await Future.delayed(
        Duration(milliseconds: amplitudeCaptureRateInMilliSeconds),
      );
      final ap = await _audioRecorder.getAmplitude();
      yield ap.current;
    }
  }

  // Get the recordings directory path
  Future<String> getRecordingsPath() async {
    try {
      Directory? externalDir = await getExternalStorageDirectory();

      externalDir ??= await getApplicationDocumentsDirectory();

      return '${externalDir.path}/recordings';
    } catch (e) {
      debugPrint('Error getting recordings path: $e');
      return '';
    }
  }
}
