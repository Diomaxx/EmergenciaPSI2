import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emergency_request.dart';

class ApiService {
  static const String _baseUrl = 'http://34.123.227.162:8080/api';
  static const String _emergencyRequestsEndpoint = '/solicitudes/apoyo';

  static Future<List<EmergencyRequest>> fetchEmergencyRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_emergencyRequestsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => EmergencyRequest.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load emergency requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching emergency requests: $e');
    }
  }

  static Future<void> acceptEmergencyHelp(int requestId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/solicitudes/aceptar-ayuda/$requestId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to accept help: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('FormatException') || e.toString().contains('SyntaxError')) {
        return;
      }
      throw Exception('Error accepting help: $e');
    }
  }

  static Future<void> sendVolunteerInfo(int requestId, Map<String, dynamic> volunteerInfo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/solicitudes/enviar-info-voluntario/$requestId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(volunteerInfo),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to send volunteer info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('FormatException') || e.toString().contains('SyntaxError')) {
        return;
      }
      throw Exception('Error sending volunteer info: $e');
    }
  }

  static List<EmergencyRequest> filterRequestsByRole(
    List<EmergencyRequest> requests,
    String userRole,
  ) {
    return requests.where((request) {
      return request.requiresPersonnel(userRole);
    }).toList();
  }
} 