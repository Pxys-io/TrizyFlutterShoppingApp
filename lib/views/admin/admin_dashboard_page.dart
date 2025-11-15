import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/multistore_integration/multistore_integration_bloc.dart';
import '../../bloc/multistore_integration/multistore_integration_event.dart';
import '../../bloc/multistore_integration/multistore_integration_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Trigger logout and redirect to login
              context.read<MultistoreIntegrationBloc>().add(ClearCurrentStore()); // Clear any selected store
              context.read<MultistoreIntegrationBloc>().add(RefreshAuthStatus()); // Will trigger redirect
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _buildDashboardCard(
              context,
              title: 'Manage Stores',
              icon: Icons.store,
              onTap: () => context.go('/admin/stores'),
            ),
            _buildDashboardCard(
              context,
              title: 'Manage Stock',
              icon: Icons.warehouse,
              onTap: () => context.go('/admin/stock'),
            ),
            const Divider(height: 30),
            Text(
              'Merchant View (Admin as Merchant)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            BlocBuilder<MultistoreIntegrationBloc, MultistoreState>(
              builder: (context, state) {
                return _buildDashboardCard(
                  context,
                  title: state.isManagingStore
                      ? 'Manage Current Store Orders (${state.currentStoreId})'
                      : 'Select Store for Merchant View',
                  icon: Icons.shopping_bag,
                  onTap: () {
                    if (state.isManagingStore) {
                      context.go('/merchant/orders/${state.currentStoreId}');
                    } else {
                      // Navigate to a store selection page or show a dialog
                      _showStoreSelectionDialog(context);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showStoreSelectionDialog(BuildContext context) {
    final TextEditingController storeIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter Store ID for Merchant View'),
          content: TextField(
            controller: storeIdController,
            decoration: const InputDecoration(hintText: 'Store ID'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Set Store'),
              onPressed: () {
                if (storeIdController.text.isNotEmpty) {
                  context.read<MultistoreIntegrationBloc>().add(SetCurrentStore(storeIdController.text));
                  Navigator.of(dialogContext).pop();
                  // Optionally navigate to merchant orders page immediately
                  context.go('/merchant/orders/${storeIdController.text}');
                }
              },
            ),
          ],
        );
      },
    );
  }
}