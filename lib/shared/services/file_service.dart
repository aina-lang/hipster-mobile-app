import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';
import 'package:flutter/foundation.dart';

class FileService {
  final Dio _dio = AppConstants.dio;

  /// Télécharge un fichier depuis une URL et l'ouvre
  /// [relativeUrl] exemple: '/invoices/12/pdf'
  /// [fileName] exemple: 'facture_12.pdf'
  Future<void> downloadAndOpenFile(String relativeUrl, String fileName) async {
    try {
      // 1. Obtenir le dossier de stockage
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String filePath = '${directory!.path}/$fileName';

      print('Downloading $relativeUrl to $filePath');

      // 2. Télécharger le fichier
      final response = await _dio.download(
        relativeUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      if (response.statusCode == 200) {
        print('File downloaded successfully: $filePath');

        // 3. Ouvrir le fichier
        final result = await OpenFilex.open(filePath);
        print('OpenFile result: ${result.message}');
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during download/open: $e');
      rethrow;
    }
  }
}
