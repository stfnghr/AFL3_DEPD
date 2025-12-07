import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:depd_mvvm_2025/data/app_exception.dart';
import 'package:depd_mvvm_2025/data/network/base_api_service.dart';
import 'package:depd_mvvm_2025/shared/shared.dart';

/// Implementasi BaseApiServices untuk menangani request GET, POST ke API RajaOngkir.
class NetworkApiServices implements BaseApiServices {
  
  Uri _buildUri(String endpoint) {
    final baseDomain = "https://${Const.baseUrl}";

    final subUrlClean = Const.subUrl.endsWith('/') 
        ? Const.subUrl.substring(0, Const.subUrl.length - 1) 
        : Const.subUrl;
    
    final endpointClean = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    Uri uri = Uri.parse('$baseDomain$subUrlClean/$endpointClean'); 
    
    return uri;
  }

  /// Melakukan request GET ke endpoint
  /// Mengembalikan JSON ter-decode atau melempar AppException yang sesuai.
  @override
  Future<dynamic> getApiResponse(String endpoint) async {
    try {
      final uri = _buildUri(endpoint); 

      // Log request GET (untuk debug: URL + header).
      _logRequest('GET', uri, Const.apiKey);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', 
          'key': Const.apiKey,
        },
        
      );

      // Penanganan respons (status + decode JSON + pemetaan error).
      return _returnResponse(response);
    } on SocketException {
      // Tidak ada koneksi jaringan.
      throw NoInternetException('');
    } on TimeoutException {
      // Waktu request melewati batas timeout.
      throw FetchDataException('Network request timeout!');
    } catch (e) {
      // Error tak terduga saat runtime.
      throw FetchDataException('Unexpected error: $e');
    }
  }

  /// Melakukan request POST dengan body form-url-encoded.
  /// Mengembalikan JSON ter-decode atau melempar AppException yang sesuai.
  @override
  Future<dynamic> postApiResponse(String endpoint, dynamic data) async {
    try {
      final uri = _buildUri(endpoint); 

      // Log request POST termasuk payload body.
      _logRequest('POST', uri, Const.apiKey, data);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'key': Const.apiKey,
        },
        body: data,
      );

      // Delegasi parsing respons dan pemetaan error.
      return _returnResponse(response);
    } on SocketException {
      // Perangkat offline.
      throw NoInternetException('No internet connection!');
    } on TimeoutException {
      // Jaringan lambat atau server tidak merespon.
      throw FetchDataException('Network request timeout!');
    } on FormatException {
      // Format respons tidak valid saat decode.
      throw FetchDataException('Invalid response format!');
    } catch (e) {
      // Fallback umum.
      throw FetchDataException('Unexpected error: $e');
    }
  }

  /// Print debug metadata request (method, URL, header, body).
  void _logRequest(String method, Uri uri, String apiKey, [dynamic data]) {
    print("== $method REQUEST ==");
    print("Final URL ($method): $uri");
    if (data != null) {
      print("Data body: $data");
    }
    print("");
  }

  /// Print debug detail respons (status, content-type, body).
  void _logResponse(int statusCode, String? contentType, String body) {
    print("Status code: $statusCode");
    print("Content-Type: ${contentType ?? '-'}");

    if (body.isEmpty) {
      print("Body: <empty>");
    } else {
      String formattedBody;
      try {
        final decoded = jsonDecode(body);
        const encoder = JsonEncoder.withIndent('  ');
        formattedBody = encoder.convert(decoded);
      } catch (_) {
        formattedBody = body;
      }

      const maxLen = 8000;
      if (formattedBody.length > maxLen) {
        print(
          "Body (terpotong): ${formattedBody.substring(0, maxLen)}... [${formattedBody.length - maxLen} lebih karakter]",
        );
      } else {
        print("Body: $formattedBody");
      }
    }
    print("");
  }

  /// Memetakan HTTP response menjadi JSON ter-decode atau melempar exception bertipe.
  dynamic _returnResponse(http.Response response) {
    _logResponse(
      response.statusCode,
      response.headers['content-type'],
      response.body,
    );

    switch (response.statusCode) {
      case 200:
        try {
          final decoded = jsonDecode(response.body);
          if (decoded == null) throw FetchDataException('Empty JSON');
          return decoded;
        } catch (_) {
          throw FetchDataException('Invalid JSON');
        }

      case 400:
        throw BadRequestException(response.body);

      case 404:
        throw NotFoundException('Not Found: ${response.body}');

      case 500:
        throw ServerErrorException('Server error: ${response.body}');

      default:
        throw FetchDataException(
          'Unexpected status ${response.statusCode}: ${response.body}',
        );
    }
  }
}