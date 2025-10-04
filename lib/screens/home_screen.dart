import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
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

  @override
  void initState() {
    super.initState();
    // _buildNavigationItems will be called in didChangeDependencies
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
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
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
                  title: 'Ventas Hoy',
                  value: 'Bs. 2,450',
                  icon: Icons.attach_money,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Pedidos',
                  value: '12',
                  icon: Icons.shopping_cart,
                  color: Colors.purple,
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
  }) {
    return Card(
      elevation: 4,
      child: Padding(
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
      ),
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
