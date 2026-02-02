import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  Uri? build() => null;
  void setPath(Uri? uri) => state = uri;
}

final inputPathProvider = NotifierProvider<InputPathNotifier, Uri?>(
  InputPathNotifier.new,
);

class OutputPathNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setPath(String? path) => state = path;
}

final outputPathProvider = NotifierProvider<OutputPathNotifier, String?>(
  OutputPathNotifier.new,
);

class CameraModelNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setModel(String model) => state = model;
}

final cameraModelProvider = NotifierProvider<CameraModelNotifier, String>(
  CameraModelNotifier.new,
);

class CameraMakerNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setMaker(String maker) => state = maker;
}

final cameraMakerProvider = NotifierProvider<CameraMakerNotifier, String>(
  CameraMakerNotifier.new,
);
