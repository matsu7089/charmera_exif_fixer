import 'dart:io';

import 'package:native_exif/native_exif.dart';
import 'package:shared_storage/shared_storage.dart' as saf;

class ExifProcessor {
  final Uri inputUri;
  final String outputPath;
  final String? cameraModel;
  final String? cameraMaker;
  final Function(String) onProgress;
  final Function(String) onLog;

  ExifProcessor({
    required this.inputUri,
    required this.outputPath,
    this.cameraModel,
    this.cameraMaker,
    required this.onProgress,
    required this.onLog,
  });

  Future<Map<String, int>> run() async {
    int successCount = 0;
    int failCount = 0;

    try {
      // Start listing files
      final fileStream = saf.listFiles(
        inputUri,
        columns: [
          saf.DocumentFileColumn.displayName,
          saf.DocumentFileColumn.lastModified,
          saf.DocumentFileColumn.mimeType,
          saf.DocumentFileColumn.id,
        ],
      );

      final List<saf.DocumentFile> allFiles = [];
      await for (final file in fileStream) {
        allFiles.add(file);
      }

      final imageFiles = allFiles.where((f) {
        final lower = f.name?.toLowerCase() ?? '';
        return lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.heic');
      }).toList();

      onLog('Found ${imageFiles.length} images.');

      for (final file in imageFiles) {
        if (file.name == null) continue;

        onProgress(file.name!);

        try {
          // 2. Read content
          final bytes = await saf.getDocumentContent(file.uri);
          if (bytes == null) {
            throw Exception('Failed to read file content');
          }

          // 3. Write to output
          final outVal = File('$outputPath/${file.name}');
          await outVal.writeAsBytes(bytes);

          // 4. Modify Exif
          final exif = await Exif.fromPath(outVal.path);

          String? originalDate = await exif.getAttribute('DateTimeOriginal');
          if (originalDate == null || originalDate.isEmpty) {
            originalDate = await exif.getAttribute('DateTimeDigitized');
          }
          if (originalDate == null || originalDate.isEmpty) {
            originalDate = await exif.getAttribute('DateTime');
          }

          final Map<String, Object> attributesToWrite = {};

          if (originalDate != null && originalDate.isNotEmpty) {
            String finalDate = originalDate;

            // Fix format: "2026:01:31:19:39:05" -> "2026:01:31 19:39:05"
            // Check if it matches the malformed pattern with 5 colons
            final parts = originalDate.split(':');
            if (parts.length == 6) {
              // It seems to be formatted as YYYY:MM:DD:HH:MM:SS
              final datePart = parts.sublist(0, 3).join(':');
              final timePart = parts.sublist(3).join(':');
              finalDate = '$datePart $timePart';
            } else if (RegExp(
              r'^\d{4}:\d{2}:\d{2}:\d{2}:\d{2}:\d{2}$',
            ).hasMatch(originalDate)) {
              finalDate = originalDate.replaceFirst(':', ' ', 10);
            }

            attributesToWrite['DateTimeOriginal'] = finalDate;
            attributesToWrite['DateTimeDigitized'] = finalDate;
            attributesToWrite['DateTime'] = finalDate;
          }

          if (cameraMaker != null && cameraMaker!.isNotEmpty) {
            attributesToWrite['Make'] = cameraMaker!;
          }

          if (cameraModel != null && cameraModel!.isNotEmpty) {
            attributesToWrite['Model'] = cameraModel!;
          }

          if (attributesToWrite.isNotEmpty) {
            await exif.writeAttributes(attributesToWrite);
          }

          await exif.close();

          successCount++;
        } catch (e) {
          onLog('Error processing ${file.name}: $e');
          failCount++;
        }
      }
    } catch (e) {
      onLog('Fatal error: $e');
    }

    return {'success': successCount, 'fail': failCount};
  }
}
