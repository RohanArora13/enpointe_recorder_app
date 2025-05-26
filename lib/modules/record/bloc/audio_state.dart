part of 'audio_cubit.dart';

abstract class AudioState {}

class AudioInitial extends AudioState {}

class RecordOn extends AudioState {
  int min = 0;
  int sec = 0;
}

class RecordStopped extends AudioState {}

class RecordError extends AudioState {}
