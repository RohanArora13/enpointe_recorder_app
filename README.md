# Audio Recorder App

A Flutter-based audio recording application built for Enpointe assignment. This app provides a clean, modern interface for recording, storing, and managing audio files 

## Video Demo
https://www.youtube.com/watch?v=9w-w8P4hbZU

## APK Download
https://drive.google.com/file/d/1FK6kzwcZm5AxNnX9wR-m__z5SZkVIkcQ/view?usp=sharing

## 📱 Features

- **Real-time Audio Recording**: High-quality audio recording with AAC-LC encoding
- **Live Audio Visualization**: Smooth animated bars showing real-time audio amplitude
- **Recording Management**: Save, view, and delete recordings with metadata
- **History Screen**: Organized recording history grouped by month
- **Permission Handling**: Robust permission management for microphone and storage
- **Dark Theme**: Modern dark UI with Material Design 3

## 🏗️ Architecture

The app follows **Clean Architecture** principles with **BLoC Pattern** for state management:

```
lib/
├── app/                    # App configuration and setup
├── core/                   # Core utilities and services
├── data/                   # Data models and repositories
├── modules/                # Feature modules
└── main.dart              # App entry point
```

### Architecture Layers

1. **Presentation Layer**: UI components and BLoC state management
2. **Domain Layer**: Business logic and use cases
3. **Data Layer**: Models, services, and data sources

## 📱 Main Screens

### 1. Home Screen (`lib/modules/home/screen/home_screen.dart`)

The main recording interface featuring:

- **Recording Button**: Large circular button to start/stop recording
- **Timer Display**: Shows recording duration in MM:SS format
- **Audio Visualizer**: Real-time amplitude visualization with smooth animated bars
- **History Navigation**: Quick access to recording history
- **App Lifecycle Management**: Handles recording state during app backgrounding

**Key Features:**
- Real-time recording timer
- Smooth audio amplitude visualization
- Automatic recording stop on app lifecycle changes
- Material Design 3 theming

### 2. History Screen (`lib/modules/history/screen/history_screen.dart`)

Displays all recorded audio files with:

- **Monthly Grouping**: Recordings organized by month/year
- **Recording Details**: Name, duration, timestamp, and file format
- **Pull-to-Refresh**: Refresh recording list
- **Empty State**: User-friendly message when no recordings exist
- **Error Handling**: Graceful error states with retry options

**Key Features:**
- Chronological organization
- Responsive loading states
- Error recovery mechanisms

## 🧩 BLoC Pattern Implementation

### 1. AudioCubit (`lib/modules/record/bloc/audio_cubit.dart`)

Manages audio recording operations:

**States:**
- `AudioInitial`: Initial state
- `RecordOn`: Recording in progress
- `RecordStopped`: Recording completed

**Key Methods:**
- `startRecording()`: Initiates audio recording with permission checks
- `stopRecording()`: Stops recording and triggers save process
- `aplitudeStream()`: Provides real-time amplitude data for visualization
- `checkMicPermission()`: Handles microphone permission requests

**Features:**
- AAC-LC encoding at 44.1kHz, 128kbps
- External storage management
- Real-time amplitude monitoring
- Comprehensive error handling

### 2. RecordBloc (`lib/modules/record/bloc/record_bloc.dart`)

Manages recording persistence and history:

**Events:**
- `SaveRecordingEvent`: Save recording to database
- `LoadRecordingsEvent`: Load all recordings
- `RefreshRecordingsEvent`: Refresh recording list
- `DeleteRecordingEvent`: Delete specific recording

**States:**
- `RecordInitial`: Initial state
- `RecordSaving`: Saving in progress
- `RecordSavedState`: Recording saved successfully
- `RecordingsLoadingState`: Loading recordings
- `RecordingsLoadedState`: Recordings loaded
- `RecordingsEmptyState`: No recordings found
- `RecordingsErrorState`: Error occurred

**Key Features:**
- Automatic recording naming
- Audio duration calculation
- Database persistence
- File system management

## 🛠️ Core Services

### 1. DatabaseService (`lib/core/services/database_service.dart`)

SQLite-based local storage service:

**Database Schema:**
```sql
CREATE TABLE recordings (
  unique_id TEXT PRIMARY KEY,
  timestamp TEXT NOT NULL,
  record_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_format TEXT NOT NULL,
  total_time INTEGER NOT NULL
)
```

**Key Methods:**
- `insertRecording()`: Save recording metadata
- `getAllRecordings()`: Retrieve all recordings
- `deleteRecording()`: Remove recording
- `getTotalRecordingsCount()`: Get recording count
- `searchRecordingsByName()`: Search functionality

**Features:**
- Singleton pattern implementation
- External storage database location
- Comprehensive CRUD operations
- Error handling and logging

### 2. PermissionService (`lib/core/services/permission_service.dart`)

Robust permission management system:

**Permissions Handled:**
- Microphone access
- Storage access
- External storage management

**Key Features:**
- Retry mechanism with exponential backoff
- Detailed permission status reporting
- Cross-platform compatibility
- Graceful error handling

**Methods:**
- `requestAllPermissions()`: Request all required permissions
- `requestMicrophonePermission()`: Microphone-specific permission
- `areAllPermissionsGranted()`: Check permission status
- `getPermissionStatusDetails()`: Detailed permission info

### 3. Audio Controller (`lib/core/services/audio_controller.dart`)

Manages audio playback and file operations (if implemented).

## 🎨 UI Components

### 1. SmoothBarVisualizer (`lib/core/widgets/smooth_bar_visualizer.dart`)

Real-time audio visualization widget:

**Features:**
- 12 animated bars with frequency-based distribution
- Smooth easing animations with staggered timing
- Gradient colors using theme colors
- Responsive to audio amplitude changes
- Configurable bar count, height, and width

**Technical Details:**
- Uses multiple `AnimationController`s for smooth transitions
- Implements frequency-based amplitude distribution
- Cubic easing curves for natural motion
- Real-time amplitude normalization

### 2. RecordingItemWidget (`lib/modules/history/widgets/recording_item_widget.dart`)

Individual recording display component with playback controls and metadata.

## 📊 Data Models

### RecordingModel (`lib/data/model/recording_model.dart`)

Core data model for audio recordings:

```dart
class RecordingModel {
  final String uniqueId;        // UUID for unique identification
  final DateTime timestamp;     // Recording creation time
  final String recordName;      // User-friendly name
  final String filePath;        // File system path
  final String fileFormat;      // Audio format (m4a)
  final Duration totalTime;     // Recording duration
}
```

**Features:**
- JSON serialization/deserialization
- Immutable design with `copyWith` method
- Formatted duration display
- File extension extraction
- Comprehensive equality comparison

## 🔧 Configuration

### Constants (`lib/core/constants/audio_constant.dart`)

Application-wide constants:

```dart
abstract class Constants {
  static const amplitudeCaptureRateInMilliSeconds = 100;
  static const double decibleLimit = -30;
  static const String fileExtention = '.m4a';
  static const String fileExtentionNoDot = 'm4a';
}
```

### Dependency Injection (`lib/app/dependency_injection.dart`)

Uses `GetIt` for service locator pattern:

```dart
void setupDependencyInjection() {
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerFactory<AudioCubit>(() => AudioCubit());
  getIt.registerFactory<RecordBloc>(() => RecordBloc());
}
```

## 📦 Dependencies

### Core Dependencies
- **flutter_bloc**: ^8.1.3 - State management
- **just_audio**: ^0.9.36 - Audio playback
- **record**: ^5.0.4 - Audio recording
- **permission_handler**: ^11.1.0 - Permission management
- **sqflite**: ^2.3.0 - Local database
- **path_provider**: ^2.1.1 - File system access
- **get_it**: ^7.6.0 - Dependency injection
- **uuid**: ^4.5.1 - Unique ID generation
- **intl**: ^0.19.0 - Internationalization
- **font_awesome_flutter**: ^10.8.0 - Icons

### Development Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: ^5.0.0 - Linting rules
- **flutter_launcher_icons**: ^0.14.3 - App icon generation


### Platform-Specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: Latest
- Permissions automatically handled by the app

#### iOS
- iOS 11.0+
- Microphone usage description in Info.plist
- Background audio capabilities if needed

## 🔒 Permissions

The app requires the following permissions:

### Android
- `RECORD_AUDIO`: Microphone access for recording
- `WRITE_EXTERNAL_STORAGE`: File storage (API < 29)
- `MANAGE_EXTERNAL_STORAGE`: File management (API 30+)

### iOS
- `NSMicrophoneUsageDescription`: Microphone access
- `NSDocumentsFolderUsageDescription`: Document access

## 📁 File Storage

### Storage Strategy
- **Android**: `/storage/emulated/0/Android/data/com.example.audio_app/files/recordings/`
- **iOS**: App Documents directory
- **Database**: Same directory as recordings

### File Format
- **Audio Format**: AAC-LC (.m4a)
- **Sample Rate**: 44.1 kHz
- **Bit Rate**: 128 kbps
- **Naming**: Timestamp-based unique names

## 🎯 App Flow

1. **App Launch**: 
   - Initialize dependencies
   - Request permissions
   - Setup BLoC providers

2. **Recording Process**:
   - User taps record button
   - Check microphone permissions
   - Start audio recording with visualization
   - Display real-time timer and amplitude
   - Stop recording and save to storage
   - Save metadata to database

3. **History Management**:
   - Load recordings from database
   - Display in chronological order
   - Allow playback and deletion
   - Refresh functionality

## 🐛 Error Handling

The app implements comprehensive error handling:

- **Permission Errors**: Graceful permission request with retry
- **Storage Errors**: Fallback storage locations
- **Recording Errors**: User feedback and recovery options
- **Database Errors**: Transaction rollback and error reporting
- **Network Errors**: Offline-first approach

## 🔄 State Management Flow

```
User Action → Event → BLoC → State → UI Update
     ↓
Permission Check → Service Call → Database/File Operation → State Emission
```

## 🧪 Testing

### Unit Tests
- BLoC testing for state management
- Service testing for core functionality
- Model testing for data integrity

### Widget Tests
- UI component testing
- User interaction testing
- State-driven UI testing

### Potential Improvements
- Recording editing capabilities
- Cloud storage integration
- Audio format conversion
- Recording sharing functionality
- Recording categories/tags
- Audio quality settings

## 📄 License

This project is created for Enpoint assignment purposes.
