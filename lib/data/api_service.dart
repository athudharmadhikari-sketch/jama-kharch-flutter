import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction_model.dart';

class ApiService {
  // ============================================================
  // BASE URL
  // ============================================================

  static const String baseUrl =
      'http://10.0.2.2:5000/api';

  // For physical Android phone use your computer IP:
  //
  // static const String baseUrl =
  //     'http://192.168.1.100:5000/api';

  // For deployed backend:
  //
  // static const String baseUrl =
  //     'https://your-backend-url.com/api';

  // ============================================================
  // HEADERS
  // ============================================================

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ============================================================
  // GET SUMMARY
  // ============================================================

  static Future<Map<String, dynamic>> getSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/summary'),
      headers: headers,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded =
          jsonDecode(response.body);

      return Map<String, dynamic>.from(
        decoded,
      );
    }

    throw Exception(
      _getErrorMessage(response),
    );
  }

  // ============================================================
  // GET TRANSACTIONS
  // ============================================================

  static Future<List<TransactionModel>>
      getTransactions({
    required String transactionType,
    String? search,
    String? status,
    String? type,
  }) async {
    final queryParameters =
        <String, String>{
      'transactionType': transactionType,
    };

    if (search != null &&
        search.trim().isNotEmpty) {
      queryParameters['search'] =
          search.trim();
    }

    if (status != null &&
        status.trim().isNotEmpty) {
      queryParameters['status'] = status;
    }

    if (type != null &&
        type.trim().isNotEmpty) {
      queryParameters['type'] = type;
    }

    final uri = Uri.parse(
      '$baseUrl/transactions',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded =
          jsonDecode(response.body);

      final List data =
          decoded['data'] ?? [];

      return data
          .map(
            (item) =>
                TransactionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw Exception(
      _getErrorMessage(response),
    );
  }

  // ============================================================
  // CREATE TRANSACTION
  // ============================================================

  static Future<TransactionModel>
      createTransaction({
    required String name,
    required DateTime date,
    required String type,
    required double amount,
    required String status,
    required String transactionType,
  }) async {
    final body = {
      'name': name.trim(),
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'status': status,
      'transactionType': transactionType,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded =
          jsonDecode(response.body);

      return TransactionModel.fromJson(
        Map<String, dynamic>.from(
          decoded['data'],
        ),
      );
    }

    throw Exception(
      _getErrorMessage(response),
    );
  }

  // ============================================================
  // UPDATE TRANSACTION
  // ============================================================

  static Future<TransactionModel>
      updateTransaction({
    required String id,
    required String name,
    required DateTime date,
    required String type,
    required double amount,
    required String status,
  }) async {
    final body = {
      'name': name.trim(),
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'status': status,
    };

    final response = await http.put(
      Uri.parse(
        '$baseUrl/transactions/$id',
      ),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded =
          jsonDecode(response.body);

      return TransactionModel.fromJson(
        Map<String, dynamic>.from(
          decoded['data'],
        ),
      );
    }

    throw Exception(
      _getErrorMessage(response),
    );
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  static Future<void> deleteTransaction(
    String id,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/transactions/$id',
      ),
      headers: headers,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(response),
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  static String _getErrorMessage(
    http.Response response,
  ) {
    try {
      final decoded =
          jsonDecode(response.body);

      return decoded['message'] ??
          'Request failed (${response.statusCode})';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }
}