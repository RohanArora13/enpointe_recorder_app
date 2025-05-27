import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../app/app.dart';
import '../widgets/recording_item_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load recordings when the screen initializes
    context.read<RecordBloc>().add(LoadRecordingsEvent());
  }

  Map<String, List<RecordingModel>> _groupRecordingsByMonth(
    List<RecordingModel> recordings,
  ) {
    final Map<String, List<RecordingModel>> grouped = {};

    for (final recording in recordings) {
      final monthYear = DateFormat('MMMM yyyy').format(recording.timestamp);
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(recording);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Recording History',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RecordBloc>().add(RefreshRecordingsEvent());
          // Wait a bit for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocBuilder<RecordBloc, RecordState>(
          builder: (context, state) {
            return _buildBody(state, colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildBody(RecordState state, ColorScheme colorScheme) {
    if (state is RecordingsLoadingState) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading recordings...',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // if there is error while recording loading state
    if (state is RecordingsErrorState) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.triangleExclamation,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  state.error,
                  style: TextStyle(color: colorScheme.error, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RecordBloc>().add(RefreshRecordingsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is RecordingsEmptyState) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.microphone,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'No recordings yet',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start recording to see your audio files here',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is RecordingsLoadedState) {
      final groupedRecordings = _groupRecordingsByMonth(state.recordings);

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: groupedRecordings.length,
        itemBuilder: (context, index) {
          final monthYear = groupedRecordings.keys.elementAt(index);
          final recordings = groupedRecordings[monthYear]!;

          return _buildMonthSection(monthYear, recordings, colorScheme);
        },
      );
    }

    // Default case - should not happen but provides fallback
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.microphone,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No recordings yet',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start recording to see your audio files here',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSection(
    String monthYear,
    List<RecordingModel> recordings,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 16),
          child: Text(
            monthYear,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...recordings.map(
          (recording) => RecordingItemWidget(recording: recording),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
