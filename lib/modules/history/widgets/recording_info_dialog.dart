import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../data/model/recording_model.dart';

class RecordingInfoDialog extends StatelessWidget {
  final RecordingModel recording;

  const RecordingInfoDialog({
    super.key,
    required this.recording,
  });

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
          _buildInfoRow('Name', recording.recordName, colorScheme),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Recorded Time',
            '${dateFormat.format(recording.timestamp)} at ${timeFormat.format(recording.timestamp)}',
            colorScheme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Duration', recording.formattedDuration, colorScheme),
          const SizedBox(height: 12),
          _buildInfoRow('Format', recording.fileFormat.toUpperCase(), colorScheme),
          const SizedBox(height: 12),
          _buildInfoRow('File Path', recording.filePath, colorScheme, isPath: true),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme, {bool isPath = false}) {
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

  static void show(BuildContext context, RecordingModel recording) {
    showDialog(
      context: context,
      builder: (BuildContext context) => RecordingInfoDialog(recording: recording),
    );
  }
}