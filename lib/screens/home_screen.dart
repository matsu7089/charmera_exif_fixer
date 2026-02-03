import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shared_storage/shared_storage.dart' as saf;
import 'package:file_picker/file_picker.dart';

import '../providers/app_state.dart';
import '../logic/exif_processor.dart';
import '../widgets/process_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _makerController;
  late TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    _makerController = TextEditingController(
      text: ref.read(cameraMakerProvider),
    );
    _modelController = TextEditingController(
      text: ref.read(cameraModelProvider),
    );
  }

  @override
  void dispose() {
    _makerController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputUri = ref.watch(inputPathProvider);
    final outputPath = ref.watch(outputPathProvider);
    final isProcessing = ref.watch(processingProvider).isProcessing;

    return Scaffold(
      appBar: AppBar(title: const Text('Charmera Exif Fixer')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Input Folder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Gap(8),
                      Text(inputUri?.toString() ?? 'No folder selected'),
                      const Gap(8),
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final uri = await saf.openDocumentTree();
                                if (uri != null) {
                                  ref
                                      .read(inputPathProvider.notifier)
                                      .setPath(uri);
                                }
                              },
                        child: const Text('Select Input Folder'),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              // Output Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Output Folder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Gap(8),
                      Text(outputPath ?? 'No folder selected'),
                      const Gap(8),
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () async {
                                String? result = await FilePicker.platform
                                    .getDirectoryPath();
                                if (result != null) {
                                  ref
                                      .read(outputPathProvider.notifier)
                                      .setPath(result);
                                }
                              },
                        child: const Text('Select Output Folder'),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              // Options
              TextField(
                controller: _makerController,
                decoration: const InputDecoration(
                  labelText: 'Camera Maker (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(cameraMakerProvider.notifier).setMaker(value);
                },
              ),
              const Gap(16),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Camera Model Name (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(cameraModelProvider.notifier).setModel(value);
                },
              ),
              // Start Button
              const Gap(32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (inputUri != null && outputPath != null && !isProcessing)
                      ? () => _startProcessing(context, ref)
                      : null,
                  child: const Text('Start Processing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startProcessing(BuildContext context, WidgetRef ref) async {
    final inputUri = ref.read(inputPathProvider);
    final outputPath = ref.read(outputPathProvider);
    final cameraModel = ref.read(cameraModelProvider);
    final cameraMaker = ref.read(cameraMakerProvider);

    if (inputUri == null || outputPath == null) return;

    ref
        .read(processingProvider.notifier)
        .startProcessing(0); // Total unknown initially or we scan first

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProcessDialog(),
    );

    // Run logic
    // We might want to count files first?
    // For simplicity, let's just run and count as we go or update total if logic allows.
    // Our ExifProcessor lists files first.

    final processor = ExifProcessor(
      inputUri: inputUri,
      outputPath: outputPath,
      cameraModel: cameraModel,
      cameraMaker: cameraMaker,
      onProgress: (fileName) {
        ref.read(processingProvider.notifier).updateProgress(fileName);
      },
      onLog: (msg) {
        ref.read(processingProvider.notifier).addLog(msg);
      },
    );

    // We need to fetch total count first to show progress bar properly?
    // ExifProcessor logic currently lists files inside run().
    // We can refactor ExifProcessor to split listing and processing, but for now
    // let's just pass a generic total or update it when listing is done.

    // Actually, let's just run it. The processor can update total?
    // We didn't add setTotal method to notifier but we have startProcessing(total).
    // Let's rely on processor returning stats or refactor slightly.
    // Ideally we count first.

    // Quick fix: Let logic handle it.

    // Run in Isolate if needed, but for now running on main thread via async (shared_storage uses platform channel).
    // Large folder might freeze UI during listing.

    final result = await processor.run();

    ref.read(processingProvider.notifier).finishProcessing();

    // Show summary
    if (context.mounted) {
      Navigator.of(
        context,
      ).pop(); // Close progress dialog (or keep it open with 'Close' button)

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Finished'),
          content: Text(
            'Success: ${result['success']}\nFailed: ${result['fail']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
