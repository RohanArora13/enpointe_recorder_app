part of 'record_bloc.dart';

@immutable
abstract class RecordEvent {}

class SaveRecordingEvent extends RecordEvent {
  final String filePath;

  SaveRecordingEvent({required this.filePath});
}

class LoadRecordingsEvent extends RecordEvent {}

class RefreshRecordingsEvent extends RecordEvent {}
