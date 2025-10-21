import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'api_service.dart';

class PedidoService {
  final ApiService _apiService = ApiService();

  /// Crear una nueva proforma/pedido
  ///
  /// Parámetros:
  /// - direccionId: ID de la dirección de entrega
  /// - items: Lista de items del carrito con formato {producto_id, cantidad, precio_unitario}
  /// - fechaProgramada: Fecha programada de entrega (opcional)
  /// - horaInicio: Hora de inicio preferida (opcional)
  /// - horaFin: Hora de fin preferida (opcional)
  /// - observaciones: Observaciones adicionales (opcional)
  Future<ApiResponse<Pedido>> crearPedido({
    required int direccionId,
    required List<Map<String, dynamic>> items,
    DateTime? fechaProgramada,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    String? observaciones,
  }) async {
    try {
      // Preparar el cuerpo de la petición
      final Map<String, dynamic> requestBody = {
        'direccion_id': direccionId,
        'items': items,
      };

      // Agregar campos opcionales si están presentes
      if (fechaProgramada != null) {
        requestBody['fecha_programada'] = fechaProgramada.toIso8601String();
      }

      if (horaInicio != null) {
        requestBody['hora_inicio_preferida'] = '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';
      }

      if (horaFin != null) {
        requestBody['hora_fin_preferida'] = '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';
      }

      if (observaciones != null && observaciones.isNotEmpty) {
        requestBody['observaciones'] = observaciones;
      }

      debugPrint('📦 Creando pedido con ${items.length} items');

      final response = await _apiService.post(
        '/app/pedidos',
        data: requestBody,
      );

      final apiResponse = ApiResponse<Pedido>.fromJson(
        response.data,
        (data) => Pedido.fromJson(data),
      );

      return apiResponse;
    } on DioException catch (e) {
      return ApiResponse<Pedido>(
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<Pedido>(
        success: false,
        message: 'Error inesperado al crear pedido: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Obtener historial de pedidos del cliente autenticado
  ///
  /// Parámetros:
  /// - page: Número de página (default: 1)
  /// - perPage: Items por página (default: 15)
  /// - estado: Filtrar por estado (opcional)
  /// - fechaDesde: Filtrar desde fecha (opcional)
  /// - fechaHasta: Filtrar hasta fecha (opcional)
  Future<PaginatedResponse<Pedido>> getPedidosCliente({
    int page = 1,
    int perPage = 15,
    EstadoPedido? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (estado != null) {
        queryParams['estado'] = EstadoInfo.enumToString(estado);
      }

      if (fechaDesde != null) {
        queryParams['fecha_desde'] = fechaDesde.toIso8601String();
      }

      if (fechaHasta != null) {
        queryParams['fecha_hasta'] = fechaHasta.toIso8601String();
      }

      final response = await _apiService.get(
        '/app/cliente/pedidos',
        queryParameters: queryParams,
      );

      return PaginatedResponse<Pedido>.fromJson(
        response.data,
        (json) => Pedido.fromJson(json),
      );
    } on DioException catch (e) {
      return PaginatedResponse<Pedido>(
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    } catch (e) {
      return PaginatedResponse<Pedido>(
        success: false,
        message: 'Error inesperado al obtener pedidos: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Obtener detalle completo de un pedido
  ///
  /// Incluye: cliente, dirección, items, historial de estados, reservas
  Future<ApiResponse<Pedido>> getPedido(int id) async {
    try {
      final response = await _apiService.get('/app/pedidos/$id');

      final apiResponse = ApiResponse<Pedido>.fromJson(
        response.data,
        (data) => Pedido.fromJson(data),
      );

      return apiResponse;
    } on DioException catch (e) {
      return ApiResponse<Pedido>(
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<Pedido>(
        success: false,
        message: 'Error inesperado al obtener pedido: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Consultar solo el estado actual del pedido (lightweight)
  ///
  /// Útil para polling o actualizaciones rápidas sin cargar toda la data
  Future<ApiResponse<Map<String, dynamic>>> getEstadoPedido(int id) async {
    try {
      final response = await _apiService.get('/app/pedidos/$id/estado');

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error inesperado al obtener estado: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Extender las reservas de stock de un pedido
  ///
  /// Útil cuando el cliente necesita más tiempo antes de que expire la reserva
  Future<ApiResponse<void>> extenderReservas(int pedidoId) async {
    try {
      final response = await _apiService.post(
        '/app/pedidos/$pedidoId/extender-reservas',
      );

      return ApiResponse<void>.fromJson(
        response.data,
        (data) => null,
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error inesperado al extender reservas: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Verificar disponibilidad de stock antes de crear pedido
  Future<ApiResponse<Map<String, dynamic>>> verificarStock(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await _apiService.post(
        '/app/verificar-stock',
        data: {'items': items},
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error inesperado al verificar stock: ${e.toString()}',
        data: null,
      );
    }
  }

  // Helper para extraer mensaje de error de DioException
  String _getErrorMessage(DioException e) {
    if (e.response != null) {
      // El servidor respondió con un error
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        // Intentar extraer el mensaje del response
        if (data.containsKey('message')) {
          return data['message'] as String;
        } else if (data.containsKey('error')) {
          return data['error'] as String;
        } else if (data.containsKey('errors')) {
          // Validaciones de Laravel
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first as String;
          }
          return 'Error de validación';
        }
      }

      return 'Error del servidor: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. Verifica tu conexión.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar al servidor. Verifica tu conexión.';
    } else {
      return 'Error de red: ${e.message}';
    }
  }
}
