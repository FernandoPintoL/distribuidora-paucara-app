import 'package:flutter/foundation.dart';
import 'localidad.dart';
import 'client.dart';
import 'product.dart';

class PaginatedResponse<T> {
  final bool success;
  final String message;
  final PaginatedData<T>? data;

  PaginatedResponse({required this.success, required this.message, this.data});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? PaginatedData.fromJson(json['data'], fromJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class PaginatedData<T> {
  final int currentPage;
  final List<T> data;
  final int perPage;
  final int total;

  PaginatedData({
    required this.currentPage,
    required this.data,
    required this.perPage,
    required this.total,
  });

  // Getter para calcular si hay más páginas
  bool get hasMorePages => currentPage * perPage < total;

  // Getter para obtener el número total de páginas
  int get totalPages => (total / perPage).ceil();

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List).map((item) => fromJson(item)).toList(),
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data,
      'per_page': perPage,
      'total': total,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    dynamic Function(Map<String, dynamic>)? fromJson,
  ]) {
    try {
      if (json.containsKey('data')) {
        // Wrapped format: {success: true, message: ..., data: ...}
        dynamic rawData = json['data'];

        dynamic processedData;
        if (rawData != null && fromJson != null) {
          // Check if data is a list and we need to process each item
          if (rawData is List) {
            // For List<T>, apply fromJson to each item
            // The result will be List<dynamic> but containing correctly typed objects
            final List<dynamic> rawList = rawData;
            final List<dynamic> processedList = rawList
                .map((item) => fromJson(item))
                .toList();
            // Try to cast the list to the correct type based on T
            if (T.toString() == 'List<Localidad>') {
              processedData = processedList.cast<Localidad>().toList();
            } else if (T.toString() == 'List<Client>') {
              processedData = processedList.cast<Client>().toList();
            } else if (T.toString() == 'List<ClientAddress>') {
              processedData = processedList.cast<ClientAddress>().toList();
            } else if (T.toString() == 'List<Product>') {
              processedData = processedList.cast<Product>().toList();
            } else {
              processedData = processedList;
            }
          } else if (rawData is Map<String, dynamic> &&
              rawData.containsKey('data') &&
              rawData['data'] is List) {
            // Es una respuesta paginada
            final List<dynamic> rawList = rawData['data'];
            final List<dynamic> processedList = rawList
                .map((item) => fromJson(item))
                .toList();
            // Try to cast the list to the correct type based on T
            if (T.toString() == 'List<Map<String, dynamic>>') {
              processedData = processedList
                  .cast<Map<String, dynamic>>()
                  .toList();
            } else {
              processedData = processedList;
            }
          } else if (rawData is Map<String, dynamic>) {
            // For single object, apply fromJson directly
            processedData = fromJson(rawData);
          } else {
            // For other types, use as is
            processedData = rawData;
          }
        } else {
          processedData = rawData;
        }

        // Assign processedData directly without casting
        return ApiResponse<T>(
          success: json['success'] ?? false,
          message: json['message'] ?? '',
          data: processedData,
        );
      } else {
        // Direct format: the data itself
        return ApiResponse<T>(
          success: true,
          message: '',
          data: fromJson != null ? fromJson(json) : null,
        );
      }
    } catch (e) {
      debugPrint('❌ Error parsing ApiResponse: $e, json: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data};
  }
}
