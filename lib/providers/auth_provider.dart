import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../services/services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final WebSocketService _wsService = WebSocketService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _authService.login(login, password);
      debugPrint(
        'Login response: success=${response.success}, data=${response.data != null ? 'not null' : 'null'}',
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        debugPrint('✅ User assigned in login: $_user');
        debugPrint('isLoggedIn: $isLoggedIn');
        _errorMessage = null;

        // Conectar al WebSocket después de login exitoso
        _connectWebSocket(response.data!.token);

        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Login failed: ${response.message}');
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> register({
    required String name,
    required String usernick,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _authService.register(
        name: name,
        usernick: usernick,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _errorMessage = null;

        // Conectar al WebSocket después de registro exitoso
        _connectWebSocket(response.data!.token);

        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        _errorMessage = response.message;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> loadUser() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      debugPrint('🚫 No token found, user not logged in');
      return false;
    }

    _isLoading = true;
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      debugPrint('📡 Loading user from API...');
      final response = await _authService.getUser();

      if (response.success && response.data != null) {
        _user = response.data;
        _errorMessage = null;

        // Conectar al WebSocket si el usuario se cargó exitosamente
        final token = await _authService.getToken();
        if (token != null) {
          _connectWebSocket(token);
        }

        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        debugPrint('✅ User loaded successfully: ${_user?.name}');
        return true;
      } else {
        _errorMessage = response.message;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        debugPrint('❌ Failed to load user: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      debugPrint('💥 Exception loading user: $e');
      return false;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      debugPrint('🔄 Load user completed, isLoading set to false');
    }
  }

  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();

      if (response.success) {
        // Token refreshed successfully
        return true;
      } else {
        // Token refresh failed, logout user
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      // Desconectar del WebSocket antes de hacer logout
      _wsService.disconnect();

      await _authService.logout();
    } catch (e) {
      // Even if logout fails, we clear local data
    } finally {
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void clearError() {
    _errorMessage = null;
    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Conectar al WebSocket después de autenticación exitosa
  void _connectWebSocket(String token) {
    if (_user == null) {
      debugPrint('⚠️ No se puede conectar al WebSocket sin usuario');
      return;
    }

    // Conectar en segundo plano, no bloquear la UI
    _wsService
        .connect(
          token: token,
          userId: _user!.id,
          userType: 'cliente', // o determinar según el rol del usuario
        )
        .then((_) {
          debugPrint('✅ WebSocket conectado para usuario ${_user!.name}');
        })
        .catchError((error) {
          debugPrint('❌ Error conectando WebSocket: $error');
          // No fallar el login si el WebSocket no se conecta
        });
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    if (_user?.permissions == null) return false;
    return _user!.permissions!.contains(permission);
  }

  // Check if user has specific role
  bool hasRole(String role) {
    if (_user?.roles == null) return false;
    return _user!.roles!.contains(role);
  }

  // Check if user is admin
  bool get isAdmin => hasRole('admin');

  // Check if user can manage products
  bool get canManageProducts =>
      hasPermission('productos.precios.gestionar') ||
      hasPermission('productos.precios.calcular-ganancias') ||
      hasPermission('productos.configuracion-ganancias') ||
      hasRole('admin');

  // Check if user can manage clients (using compras permissions as proxy)
  bool get canManageClients =>
      hasPermission('compras.index') ||
      hasPermission('compras.create') ||
      hasPermission('compras.store') ||
      hasRole('admin');

  // Check if user can create products
  bool get canCreateProducts =>
      hasPermission('productos.precios.gestionar') ||
      hasPermission('productos.configuracion-ganancias') ||
      hasRole('admin');

  // Check if user can create clients
  bool get canCreateClients =>
      hasPermission('compras.create') ||
      hasPermission('compras.store') ||
      hasRole('admin');
}
