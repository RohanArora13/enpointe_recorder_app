import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';

import '../../../app/app.dart';

part 'record_event.dart';
part 'record_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final DatabaseService _databaseService = GetIt.instance<DatabaseService>();
  final Uuid _uuid = const Uuid();

  RecordBloc() : super(RecordInitial()) {
    on<SaveRecordingEvent>(_onSaveRecording);
    on<LoadRecordingsEvent>(_onLoadRecordings);
    on<RefreshRecordingsEvent>(_onRefreshRecordings);
  }

  Future<void> _onSaveRecording(
    SaveRecordingEvent event,
    Emitter<RecordState> emit,
  ) async {
    emit(RecordSaving());

    try {
      // Check if file exists
      final file = File(event.filePath);
      if (!await file.exists()) {
        emit(
          RecordSaveErrorState(
            error: 'Audio file not found at path: ${event.filePath}',
          ),
        );
        return;
      }

      // Get audio duration from direct soruce for more accurate info
      final Duration totalTime = await _getAudioDuration(event.filePath);

      // Get total recordings count for naming
      final int recordingsCount =
          await _databaseService.getTotalRecordingsCount();

      // Create recording model
      final recording = RecordingModel(
        uniqueId: _uuid.v4(),
        timestamp: DateTime.now(),
        recordName: 'New Recording ${recordingsCount + 1}',
        filePath: event.filePath,
        fileFormat: Constants.fileExtentionNoDot,
        totalTime: totalTime,
      );

      // Save to database
      final bool success = await _databaseService.insertRecording(recording);

      if (success) {
        emit(RecordSavedState(recording: recording));
        debugPrint("Recording saved success!");
      } else {
        emit(
          RecordSaveErrorState(error: 'Failed to save recording to database'),
        );
        debugPrint("Recording saved Failed!");
      }
    } catch (e) {
      emit(RecordSaveErrorState(error: 'Error saving recording: $e'));
      debugPrint("Recording saved Failed!");
    }
  }

  Future<Duration> _getAudioDuration(String filePath) async {
    try {
      final player = AudioPlayer();
      await player.setFilePath(filePath);
      final duration = player.duration ?? Duration.zero;
      await player.dispose();
      return duration;
    } catch (e) {
      // If we can't get duration, return zero
      return Duration.zero;
    }
  }

  Future<void> _onLoadRecordings(
    LoadRecordingsEvent event,
    Emitter<RecordState> emit,
  ) async {
    emit(RecordingsLoadingState());
    await _loadRecordingsFromDatabase(emit);
  }

  Future<void> _onRefreshRecordings(
    RefreshRecordingsEvent event,
    Emitter<RecordState> emit,
  ) async {
    emit(RecordingsLoadingState());
    await _loadRecordingsFromDatabase(emit);
  }

  Future<void> _loadRecordingsFromDatabase(Emitter<RecordState> emit) async {
    try {
      final recordings = await _databaseService.getAllRecordings();

      if (recordings == null || recordings.isEmpty) {
        emit(RecordingsEmptyState());
      } else {
        emit(RecordingsLoadedState(recordings: recordings));
      }
    } catch (e) {
      emit(RecordingsErrorState(error: 'Failed to load recordings: $e'));
    }
  }
}
