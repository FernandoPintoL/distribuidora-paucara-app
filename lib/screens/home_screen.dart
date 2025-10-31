import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/providers.dart';
import '../services/services.dart';
import '../config/websocket_config.dart';
import 'products/product_list_screen.dart';
import 'clients/client_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;
  late List<Map<String, dynamic>> _drawerItems;

  final _wsService = WebSocketService();
  late StreamSubscription _proformaSubscription;
  late StreamSubscription _stockSubscription;
  late StreamSubscription _connectionSubscription;

  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // _buildNavigationItems will be called in didChangeDependencies
    _setupWebSocketListeners();
    _isConnected = _wsService.isConnected;
  }

  void _setupWebSocketListeners() {
    // Escuchar estado de conexión
    _connectionSubscription = _wsService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() => _isConnected = connected);

        if (connected) {
          _showNotification('Conectado', 'Conexión establecida', Colors.green);
        } else {
          _showNotification(
            'Desconectado',
            'Sin conexión al servidor',
            Colors.red,
          );
        }
      }
    });

    // Escuchar eventos de proformas
    _proformaSubscription = _wsService.proformaStream.listen((event) {
      if (!mounted) return;

      final type = event['type'];
      final data = event['data'];

      switch (type) {
        case 'created':
          _handleProformaCreated(data);
          break;
        case 'approved':
          _handleProformaApproved(data);
          break;
        case 'rejected':
          _handleProformaRejected(data);
          break;
        case 'converted':
          _handleProformaConverted(data);
          break;
      }
    });

    // Escuchar eventos de stock
    _stockSubscription = _wsService.stockStream.listen((event) {
      if (!mounted) return;

      final type = event['type'];
      final data = event['data'];

      switch (type) {
        case 'expiring':
          _handleStockExpiring(data);
          break;
        case 'updated':
          _handleStockUpdated(data);
          break;
      }
    });

    // También puedes usar callbacks específicos
    _wsService.on(WebSocketConfig.eventPaymentConfirmed, (data) {
      if (mounted) {
        _handlePaymentConfirmed(data);
      }
    });
  }

  void _handleProformaCreated(Map<String, dynamic> data) {
    _showNotification(
      'Pedido Creado',
      'Tu pedido ${data['numero']} ha sido recibido',
      Colors.blue,
    );
  }

  void _handleProformaApproved(Map<String, dynamic> data) {
    _showNotification(
      'Pedido Aprobado',
      data['message'] ?? 'Tu pedido ha sido aprobado',
      Colors.green,
    );

    // Opcional: Navegar a detalles del pedido
    // Navigator.pushNamed(context, '/pedido-detalle', arguments: data['proforma_id']);
  }

  void _handleProformaRejected(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pedido Rechazado'),
        content: Text(data['reason'] ?? 'Tu pedido ha sido rechazado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a crear nuevo pedido
              Navigator.pushNamed(context, '/carrito');
            },
            child: const Text('Ver Carrito'),
          ),
        ],
      ),
    );
  }

  void _handleProformaConverted(Map<String, dynamic> data) {
    _showNotification(
      'Pedido Procesado',
      'Tu pedido se ha convertido en venta ${data['venta_numero']}',
      Colors.orange,
    );
  }

  void _handleStockExpiring(Map<String, dynamic> data) {
    final minutes = data['minutes_remaining'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Reserva por Vencer'),
          ],
        ),
        content: Text(
          'Tu reserva de stock expira en $minutes minutos. '
          '¿Deseas completar el pedido ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más Tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/pedido-detalle',
                arguments: data['proforma_id'],
              );
            },
            child: const Text('Ver Pedido'),
          ),
        ],
      ),
    );
  }

  void _handleStockUpdated(Map<String, dynamic> data) {
    // Actualizar UI de catálogo si estás en esa pantalla
    debugPrint(
      'Stock actualizado: ${data['nombre']} - ${data['stock_nuevo']} unidades',
    );

    // Opcional: Mostrar notificación sutil
    // _showNotification('Stock Actualizado', '${data['nombre']}', Colors.blue);
  }

  void _handlePaymentConfirmed(Map<String, dynamic> data) {
    _showNotification(
      'Pago Confirmado',
      'Pago de \$${data['monto']} confirmado',
      Colors.green,
    );
  }

  void _showNotification(String title, String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Navegar a pantalla relevante
            Navigator.pushNamed(context, '/mis-pedidos');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _proformaSubscription.cancel();
    _stockSubscription.cancel();
    _connectionSubscription.cancel();
    _wsService.off(WebSocketConfig.eventPaymentConfirmed);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildNavigationItems();
  }

  void _buildNavigationItems() {
    final authProvider = context.read<AuthProvider>();
    final screens = <Widget>[];
    final navItems = <BottomNavigationBarItem>[];
    final drawerItems = <Map<String, dynamic>>[];

    // Dashboard - always visible
    screens.add(const DashboardScreen());
    navItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    );
    drawerItems.add({
      'icon': Icons.dashboard,
      'title': 'Dashboard',
      'index': screens.length - 1,
    });

    // Products - if has product permissions
    if (authProvider.canManageProducts) {
      screens.add(const ProductListScreen());
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Productos',
        ),
      );
      drawerItems.add({
        'icon': Icons.inventory,
        'title': 'Productos',
        'index': screens.length - 1,
      });
    }

    // Clients - if has client permissions (using compras as proxy for now)
    if (authProvider.canManageClients) {
      screens.add(const ClientListScreen());
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Clientes',
        ),
      );
      drawerItems.add({
        'icon': Icons.people,
        'title': 'Clientes',
        'index': screens.length - 1,
      });
      // Set default screen to clients list
      _selectedIndex = screens.length - 1;
    }

    // Profile - always visible
    screens.add(const ProfileScreen());
    navItems.add(
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    );
    drawerItems.add({
      'icon': Icons.person,
      'title': 'Perfil',
      'index': screens.length - 1,
    });

    _screens = screens;
    _navItems = navItems;
    _drawerItems = drawerItems;

    // Adjust selected index if it's out of bounds
    if (_selectedIndex >= _screens.length) {
      _selectedIndex = 0;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuidora Paucara'),
        actions: [
          // Indicador de conexión WebSocket
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _navItems.isNotEmpty
          ? BottomNavigationBar(
              items: _navItems,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            )
          : null,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.user?.name ?? 'Usuario'),
              accountEmail: Text(authProvider.user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  (authProvider.user?.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            ..._drawerItems.map(
              (item) => ListTile(
                leading: Icon(item['icon']),
                title: Text(item['title']),
                selected: _selectedIndex == item['index'],
                onTap: () {
                  _onItemTapped(item['index']);
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Mi Carrito'),
              trailing: Consumer<CarritoProvider>(
                builder: (context, carritoProvider, _) {
                  if (carritoProvider.cantidadItems == 0) {
                    return const SizedBox.shrink();
                  }
                  return CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${carritoProvider.cantidadItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/carrito');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Mis Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/mis-pedidos');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Está seguro de que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, ${authProvider.user?.name ?? 'Usuario'}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Rol: ${authProvider.user?.roles?.join(', ') ?? 'Sin rol'}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Cards de resumen
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Productos',
                  value: '150',
                  icon: Icons.inventory,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Clientes',
                  value: '45',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Mi Carrito',
                  value: context
                      .watch<CarritoProvider>()
                      .cantidadItems
                      .toString(),
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/carrito'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Mis Pedidos',
                  value: '0',
                  icon: Icons.receipt_long,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/mis-pedidos'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            'Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Botones de acciones rápidas
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final quickActions = <Widget>[];

              if (authProvider.canCreateProducts) {
                quickActions.add(
                  Expanded(
                    child: _buildQuickActionButton(
                      title: 'Nuevo Producto',
                      icon: Icons.add_box,
                      onTap: () {
                        // TODO: Navigate to create product screen
                      },
                    ),
                  ),
                );
              }

              if (authProvider.canCreateClients) {
                quickActions.add(
                  Expanded(
                    child: _buildQuickActionButton(
                      title: 'Nuevo Cliente',
                      icon: Icons.person_add,
                      onTap: () {
                        // TODO: Navigate to create client screen
                      },
                    ),
                  ),
                );
              }

              if (quickActions.isEmpty) {
                return const SizedBox.shrink();
              }

              return Row(
                children:
                    quickActions
                        .expand((widget) => [widget, const SizedBox(width: 16)])
                        .toList()
                      ..removeLast(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return Card(
      elevation: 4,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: cardContent,
            )
          : cardContent,
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mi Perfil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      (user?.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usuario: ${user?.usernick ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: (user?.roles ?? []).map((role) {
                      return Chip(
                        label: Text(role),
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
