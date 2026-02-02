import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/app_state.dart';

class ProcessDialog extends ConsumerWidget {
  const ProcessDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(processingProvider);

    return AlertDialog(
      title: const Text('Processing...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: state.totalFiles > 0
                ? state.processedFiles / state.totalFiles
                : null,
          ),
          const Gap(16),
          Text('Processing: ${state.currentFile}'),
          Text('${state.processedFiles} / ${state.totalFiles}'),
          const Gap(16),
          const Text('Logs:'),
          Container(
            height: 100,
            width: double.maxFinite,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: ListView.builder(
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                // Show latest logs at bottom is handled by reverse or scroll
                // Simple list for now
                return Text(
                  state.logs[state.logs.length - 1 - index],
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        if (!state.isProcessing)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
      ],
    );
  }
}
