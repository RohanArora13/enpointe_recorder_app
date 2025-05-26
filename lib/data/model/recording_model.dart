class RecordingModel {
  final String uniqueId;
  final DateTime timestamp;
  final String recordName;
  final String filePath;
  final String fileFormat;
  final Duration totalTime;

  const RecordingModel({
    required this.uniqueId,
    required this.timestamp,
    required this.recordName,
    required this.filePath,
    required this.fileFormat,
    required this.totalTime,
  });

  // Named constructor for creating from JSON
  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      uniqueId: json['unique_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recordName: json['record_name'] as String,
      filePath: json['file_path'] as String,
      fileFormat: json['file_format'] as String,
      totalTime: Duration(milliseconds: json['total_time'] as int),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unique_id': uniqueId,
      'timestamp': timestamp.toIso8601String(),
      'record_name': recordName,
      'file_path': filePath,
      'file_format': fileFormat,
      'total_time': totalTime.inMilliseconds,
    };
  }

  // Copy with method for immutability
  RecordingModel copyWith({
    String? uniqueId,
    DateTime? timestamp,
    String? recordName,
    String? filePath,
    String? fileFormat,
    Duration? totalTime,
  }) {
    return RecordingModel(
      uniqueId: uniqueId ?? this.uniqueId,
      timestamp: timestamp ?? this.timestamp,
      recordName: recordName ?? this.recordName,
      filePath: filePath ?? this.filePath,
      fileFormat: fileFormat ?? this.fileFormat,
      totalTime: totalTime ?? this.totalTime,
    );
  }

  // String representation
  @override
  String toString() {
    return 'RecordingModel('
        'uniqueId: $uniqueId, '
        'timestamp: $timestamp, '
        'recordName: $recordName, '
        'filePath: $filePath, '
        'fileFormat: $fileFormat, '
        'totalTime: $totalTime'
        ')';
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordingModel &&
        other.uniqueId == uniqueId &&
        other.timestamp == timestamp &&
        other.recordName == recordName &&
        other.filePath == filePath &&
        other.fileFormat == fileFormat &&
        other.totalTime == totalTime;
  }

  // Hash code
  @override
  int get hashCode {
    return Object.hash(
      uniqueId,
      timestamp,
      recordName,
      filePath,
      fileFormat,
      totalTime,
    );
  }

  // Helper method to get formatted duration
  String get formattedDuration {
    final hours = totalTime.inHours;
    final minutes = totalTime.inMinutes.remainder(60);
    final seconds = totalTime.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Helper method to get file size if needed (placeholder)
  String get fileExtension {
    return filePath.split('.').last.toLowerCase();
  }
}