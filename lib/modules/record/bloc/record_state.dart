part of 'record_bloc.dart';

abstract class RecordState {}

class RecordInitial extends RecordState {}

class RecordSaving extends RecordState {}

class RecordSavedState extends RecordState {
  final RecordingModel recording;

  RecordSavedState({required this.recording});
}

class RecordSaveErrorState extends RecordState {
  final String error;

  RecordSaveErrorState({required this.error});
}

class RecordingsLoadingState extends RecordState {}

class RecordingsLoadedState extends RecordState {
  final List<RecordingModel> recordings;

  RecordingsLoadedState({required this.recordings});
}

class RecordingsEmptyState extends RecordState {}

class RecordingsErrorState extends RecordState {
  final String error;

  RecordingsErrorState({required this.error});
}

class RecordDeletingState extends RecordState {}

class RecordDeletedState extends RecordState {
  final RecordingModel deletedRecording;

  RecordDeletedState({required this.deletedRecording});
}

class RecordDeleteErrorState extends RecordState {
  final String error;

  RecordDeleteErrorState({required this.error});
}
