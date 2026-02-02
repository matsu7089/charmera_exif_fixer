import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charmera_exif_fixer/providers/storage_provider.dart';

class ProcessingState {
  final bool isProcessing;
  final int totalFiles;
  final int processedFiles;
  final String currentFile;
  final List<String> logs;

  ProcessingState({
    this.isProcessing = false,
    this.totalFiles = 0,
    this.processedFiles = 0,
    this.currentFile = '',
    this.logs = const [],
  });

  ProcessingState copyWith({
    bool? isProcessing,
    int? totalFiles,
    int? processedFiles,
    String? currentFile,
    List<String>? logs,
  }) {
    return ProcessingState(
      isProcessing: isProcessing ?? this.isProcessing,
      totalFiles: totalFiles ?? this.totalFiles,
      processedFiles: processedFiles ?? this.processedFiles,
      currentFile: currentFile ?? this.currentFile,
      logs: logs ?? this.logs,
    );
  }
}

class ProcessingNotifier extends Notifier<ProcessingState> {
  @override
  ProcessingState build() {
    return ProcessingState();
  }

  void startProcessing(int total) {
    state = state.copyWith(
      isProcessing: true,
      totalFiles: total,
      processedFiles: 0,
      logs: [],
    );
  }

  void updateProgress(String fileName) {
    state = state.copyWith(
      processedFiles: state.processedFiles + 1,
      currentFile: fileName,
    );
  }

  void addLog(String message) {
    state = state.copyWith(logs: [...state.logs, message]);
  }

  void finishProcessing() {
    state = state.copyWith(isProcessing: false, currentFile: '');
  }

  void reset() {
    state = ProcessingState();
  }
}

final processingProvider =
    NotifierProvider<ProcessingNotifier, ProcessingState>(
      ProcessingNotifier.new,
    );

class InputPathNotifier extends Notifier<Uri?> {
  static const _key = 'input_path';

  @override
  Uri? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final path = prefs.getString(_key);
    return path != null ? Uri.parse(path) : null;
  }

  void setPath(Uri? uri) {
    state = uri;
    final prefs = ref.read(sharedPreferencesProvider);
    if (uri != null) {
      prefs.setString(_key, uri.toString());
    } else {
      prefs.remove(_key);
    }
  }
}

final inputPathProvider = NotifierProvider<InputPathNotifier, Uri?>(
  InputPathNotifier.new,
);

class OutputPathNotifier extends Notifier<String?> {
  static const _key = 'output_path';

  @override
  String? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_key);
  }

  void setPath(String? path) {
    state = path;
    final prefs = ref.read(sharedPreferencesProvider);
    if (path != null) {
      prefs.setString(_key, path);
    } else {
      prefs.remove(_key);
    }
  }
}

final outputPathProvider = NotifierProvider<OutputPathNotifier, String?>(
  OutputPathNotifier.new,
);

class CameraModelNotifier extends Notifier<String> {
  static const _key = 'camera_model';

  @override
  String build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_key) ?? '';
  }

  void setModel(String model) {
    state = model;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_key, model);
  }
}

final cameraModelProvider = NotifierProvider<CameraModelNotifier, String>(
  CameraModelNotifier.new,
);

class CameraMakerNotifier extends Notifier<String> {
  static const _key = 'camera_maker';

  @override
  String build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_key) ?? '';
  }

  void setMaker(String maker) {
    state = maker;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_key, maker);
  }
}

final cameraMakerProvider = NotifierProvider<CameraMakerNotifier, String>(
  CameraMakerNotifier.new,
);
