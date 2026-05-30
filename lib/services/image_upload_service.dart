import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/cloudinary_config.dart';

class ImageUploadException implements Exception {
  final String message;
  final int? statusCode;
  ImageUploadException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ImageUploadException: $message'
      '${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

/// Thin wrapper around Cloudinary's unsigned upload endpoint.
///
/// We use plain `http` instead of the Cloudinary SDK to keep the dependency
/// footprint small and avoid native plugin issues. The endpoint accepts a
/// multipart POST with the file plus a preset name; nothing is signed
/// client-side, which is fine because the preset itself is registered as
/// `unsigned` in the Cloudinary dashboard and constrained server-side
/// (allowed formats, max size, etc.).
class ImageUploadService {
  final http.Client _client;

  ImageUploadService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> uploadProfilePhoto(File file, {required String uid}) {
    return _upload(file, folder: '${CloudinaryConfig.profilePhotoFolder}/$uid');
  }

  Future<String> uploadIdDocument(
    File file, {
    required String uid,
    required String slot, // 'front', 'back', 'selfie'
  }) {
    return _upload(
      file,
      folder: '${CloudinaryConfig.idVerificationFolder}/$uid',
      tags: ['id-verification', 'slot:$slot'],
    );
  }

  Future<String> _upload(
    File file, {
    required String folder,
    List<String> tags = const [],
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      throw ImageUploadException(
        'Cloudinary is not configured. Set cloudName in lib/core/cloudinary_config.dart.',
      );
    }

    final request =
        http.MultipartRequest('POST', CloudinaryConfig.uploadEndpoint)
          ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
          ..fields['folder'] = folder;

    if (tags.isNotEmpty) {
      request.fields['tags'] = tags.join(',');
    }

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    http.StreamedResponse streamed;
    try {
      streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
    } on SocketException {
      throw ImageUploadException('No internet connection.');
    } catch (e) {
      throw ImageUploadException('Upload failed: $e');
    }

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      String message = 'Upload failed';
      try {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        final err = decoded['error'];
        if (err is Map && err['message'] is String) {
          message = err['message'] as String;
        }
      } catch (_) {
        // Body wasn't JSON; keep the generic message.
      }
      throw ImageUploadException(message, statusCode: streamed.statusCode);
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = decoded['secure_url'];
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw ImageUploadException('Upload response missing secure_url.');
    }
    return secureUrl;
  }

  void dispose() {
    _client.close();
  }
}
