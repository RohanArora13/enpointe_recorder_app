import 'dart:async';
import 'package:intl/intl.dart';

import '../../../app/app.dart';

class RecordingInfoDialog extends StatefulWidget {
  final RecordingModel recording;

  const RecordingInfoDialog({super.key, required this.recording});

  @override
  State<RecordingInfoDialog> createState() => _RecordingInfoDialogState();

  static void show(BuildContext context, RecordingModel recording) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => RecordingInfoDialog(recording: recording),
    );
  }
}

class _RecordingInfoDialogState extends State<RecordingInfoDialog> {
  bool _isDeleting = false;
  Timer? _deleteTimer;
  int _countdown = 3;

  @override
  void dispose() {
    _deleteTimer?.cancel();
    super.dispose();
  }

  void _startDeleteTimer() {
    setState(() {
      _isDeleting = true;
      _countdown = 5;
    });

    _deleteTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _executeDelete();
      }
    });
  }

  void _cancelDelete() {
    _deleteTimer?.cancel();
    setState(() {
      _isDeleting = false;
      _countdown = 3;
    });
  }

  void _executeDelete() {
    // TODO: Implement delete functionality
    // This will be implemented later as requested

    BlocProvider.of<RecordBloc>(
      context,
    ).add(DeleteRecordingEvent(recording: widget.recording));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm:ss a');

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Row(
        children: [
          Icon(
            FontAwesomeIcons.circleInfo,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Recording Info',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Name', widget.recording.recordName, colorScheme),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Recorded Time',
            '${dateFormat.format(widget.recording.timestamp)} at ${timeFormat.format(widget.recording.timestamp)}',
            colorScheme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Duration',
            widget.recording.formattedDuration,
            colorScheme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Format',
            widget.recording.fileFormat.toUpperCase(),
            colorScheme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'File Path',
            widget.recording.filePath,
            colorScheme,
            isPath: true,
          ),
        ],
      ),
      actions: [
        if (_isDeleting) ...[
          TextButton(
            onPressed: _cancelDelete,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.arrowRotateLeft,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Undo ($_countdown)',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ],
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: _startDeleteTimer,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.trash,
                  size: 16,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 4),
                Text('Delete', style: TextStyle(color: colorScheme.error)),
              ],
            ),
          ),
        ],
        TextButton(
          onPressed: () {
            if (_isDeleting) {
              _executeDelete();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text('Close', style: TextStyle(color: colorScheme.primary)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isPath = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontFamily: isPath ? 'monospace' : null,
            ),
            maxLines: isPath ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
