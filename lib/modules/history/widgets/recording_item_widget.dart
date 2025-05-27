import 'package:audio_app/core/services/audio_controller.dart';
import 'package:intl/intl.dart';

import '../../../app/app.dart';
import 'recording_info_dialog.dart';

class RecordingItemWidget extends StatefulWidget {
  final RecordingModel recording;

  const RecordingItemWidget({
    super.key,
    required this.recording,
  });

  @override
  State<RecordingItemWidget> createState() => _RecordingItemWidgetState();
}

class _RecordingItemWidgetState extends State<RecordingItemWidget> {
  final AudioPlayerController _audioController = AudioPlayerController();
  String? _currentPlayingId;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    // Listen to player state changes
    _audioController.playerState.listen((playerState) {
      if (mounted) {
        setState(() {
          _isPlaying = playerState.playing;
          if (playerState.processingState == ProcessingState.completed) {
            _currentPlayingId = null;
            _currentPosition = Duration.zero;
            _isPlaying = false;
          }
        });
      }
    });

    // Listen to position changes
    _audioController.positionStream.listen((position) {
      if (mounted && _currentPlayingId != null) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }

  void _onRecordingTap() async {
    try {
      // If the same recording is currently playing, pause/stop it
      if (_currentPlayingId == widget.recording.uniqueId && _isPlaying) {
        await _audioController.stop();
        setState(() {
          _currentPlayingId = null;
          _currentPosition = Duration.zero;
          _isPlaying = false;
        });
        return;
      }

      // Stop any currently playing audio
      if (_currentPlayingId != null) {
        await _audioController.stop();
      }

      // Set the new audio file and get its duration
      final duration = await _audioController.setPath(
        filePath: widget.recording.filePath,
      );

      if (duration != null) {
        setState(() {
          _currentPlayingId = widget.recording.uniqueId;
          _totalDuration = duration;
          _currentPosition = Duration.zero;
        });

        // Start playing
        await _audioController.play();
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showRecordingInfo() {
    RecordingInfoDialog.show(context, widget.recording);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Play button - clickable area
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _onRecordingTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _currentPlayingId == widget.recording.uniqueId && _isPlaying
                            ? FontAwesomeIcons.pause
                            : FontAwesomeIcons.play,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Recording details - clickable area
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _onRecordingTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.recording.recordName,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dateFormat.format(widget.recording.timestamp)} • ${timeFormat.format(widget.recording.timestamp)}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Duration and info button - non-clickable area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        widget.recording.formattedDuration,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showRecordingInfo,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              FontAwesomeIcons.circleInfo,
                              size: 16,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Progress bar - only show when this recording is playing
              if (_currentPlayingId == widget.recording.uniqueId && _isPlaying) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _totalDuration.inMilliseconds > 0
                        ? _currentPosition.inMilliseconds /
                            _totalDuration.inMilliseconds
                        : 0.0,
                    backgroundColor: colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    minHeight: 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}