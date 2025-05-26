import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app/app.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecordStarted = false;

  // Timer related variables
  Timer? _timer;
  int _recordingDuration = 0; // in seconds

  // Method to handle record button press
  void _onRecordPressed() {
    setState(() {
      if (!_isRecordStarted) {
        // Start recording
        _isRecordStarted = true;
        _startTimer();
        context.read<AudioCubit>().startRecording();
      } else if (_isRecordStarted) {
        // Stop recording
        _isRecordStarted = false;
        _stopTimer();
        context.read<AudioCubit>().stopRecording();
      }
    });
  }

  // Start the recording timer
  void _startTimer() {
    _recordingDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  // Stop the recording timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // Format duration to MM:SS format
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get appropriate icon based on current state
  IconData _getButtonIcon() {
    if (_isRecordStarted) {
      return FontAwesomeIcons.stop;
    } else {
      return FontAwesomeIcons.microphone;
    }
  }

  // Get button color based on current state
  Color _getButtonColor() {
    if (_isRecordStarted) {
      return Colors.red.shade600;
    } else {
      return Colors.grey[600]!;
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordBloc, RecordState>(
      listener: (context, state) {
        if (state is RecordSavedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved : ${state.recording.recordName}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(),
                          ),
                        );
                      },
                      child: Text("History"),
                    ),
                  ],
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Timer indicator - visible only when recording
                        if (_isRecordStarted)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              _formatDuration(_recordingDuration),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        // StreamBuilder centered
                        Container(
                          height: 140,
                          child:
                              _isRecordStarted
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      StreamBuilder<double>(
                                        initialData: 0,
                                        stream:
                                            context
                                                .read<AudioCubit>()
                                                .aplitudeStream(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return VisualIndicator(
                                              amplitude: snapshot.data,
                                              startedAudio: _isRecordStarted,
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return const Text(
                                              'Visualizer failed to load',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            );
                                          } else {
                                            return const SizedBox();
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                  : Column(
                                    children: [
                                      Text(
                                        "Press Record to Start recording...",
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getButtonColor(),
                        ),
                        child: IconButton(
                          onPressed: _onRecordPressed,
                          icon: Icon(
                            _getButtonIcon(),
                            color: Colors.white,
                            size: 42,
                          ),
                          iconSize: 64,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
