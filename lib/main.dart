import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'widgets/realtime_notifications_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🌍 App starting...');
  // Load environment variables before initializing services/UI
  await dotenv.load(fileName: ".env");
  debugPrint('✅ .env loaded');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distribuidora Paucara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        cardTheme: CardThemeData(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductListScreen(),
        '/clients': (context) => const ClientListScreen(),
        '/carrito': (context) => const CarritoScreen(),
        '/direccion-entrega-seleccion': (context) => const DireccionEntregaSeleccionScreen(),
        '/mis-pedidos': (context) => const PedidosHistorialScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        switch (settings.name) {
          case '/fecha-hora-entrega':
            final direccion = settings.arguments as ClientAddress?;
            if (direccion == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Dirección no encontrada')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => FechaHoraEntregaScreen(direccion: direccion),
            );

          case '/resumen-pedido':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Parámetros no encontrados')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => ResumenPedidoScreen(
                direccion: args['direccion'] as ClientAddress,
                fechaProgramada: args['fechaProgramada'] as DateTime?,
                horaInicio: args['horaInicio'] as TimeOfDay?,
                horaFin: args['horaFin'] as TimeOfDay?,
                observaciones: args['observaciones'] as String?,
              ),
            );

          case '/pedido-creado':
            final pedido = settings.arguments as Pedido?;
            if (pedido == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Pedido no encontrado')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => PedidoCreadoScreen(pedido: pedido),
            );

          case '/pedido-detalle':
            final pedidoId = settings.arguments as int?;
            if (pedidoId == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: ID de pedido no encontrado')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => PedidoDetalleScreen(pedidoId: pedidoId),
            );

          case '/pedido-tracking':
            final pedido = settings.arguments as Pedido?;
            if (pedido == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Pedido no encontrado')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => PedidoTrackingScreen(pedido: pedido),
            );

          default:
            return null;
        }
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = context.read<AuthProvider>();

    try {
      // Try to load user if token exists, but never block UI indefinitely
      debugPrint('🔍 Checking auth status...');
      await Future.any([
        authProvider.loadUser(),
        Future.delayed(const Duration(seconds: 5)),
      ]);
      debugPrint('✅ Auth check completed');
    } catch (e) {
      // If there's an error loading user, ensure loading state is cleared
      debugPrint('❌ Error loading user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint(
          '🔄 AuthWrapper build - isLoading: ${authProvider.isLoading}, isLoggedIn: ${authProvider.isLoggedIn}',
        );

        // Build the appropriate screen
        late Widget screen;

        if (authProvider.isLoading) {
          debugPrint('⏳ Loading...');
          screen = const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (authProvider.isLoggedIn) {
          // Check user role to show appropriate screen
          final user = authProvider.user;
          final roles = user?.roles ?? [];

          // Case-insensitive role check (backend sends 'Cliente' with capital C)
          final isCliente = roles.any((role) => role.toLowerCase() == 'cliente');

          Widget homeScreen;
          if (isCliente) {
            debugPrint('🏠 Navigating to HomeClienteScreen (cliente role: $roles)');
            homeScreen = const HomeClienteScreen();
          } else {
            debugPrint('🏠 Navigating to ClientListScreen (preventista/chofer role: $roles)');
            homeScreen = const ClientListScreen();
          }

          // Wrap with RealtimeNotificationsListener for WebSocket notifications
          screen = RealtimeNotificationsListener(child: homeScreen);
        } else {
          debugPrint('🔐 Navigating to LoginScreen');
          screen = const LoginScreen();
        }

        // Wrap with Material and ensure it renders
        return Scaffold(
          body: screen,
        );
      },
    );
  }
}
