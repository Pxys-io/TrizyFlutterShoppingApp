import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/multistore_integration/multistore_integration_bloc.dart';
import '../../bloc/multistore_integration/multistore_integration_event.dart';
import '../../bloc/multistore_integration/multistore_integration_state.dart';

class MerchantDashboardPage extends StatelessWidget {
  const MerchantDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
      ),
      body: BlocBuilder<MultistoreIntegrationBloc, MultistoreState>(
        builder: (context, state) {
          if (!state.isAuthenticated || !state.isAdmin) {
            return const Center(child: Text('Unauthorized access. Please log in as an admin.'));
          }

          if (!state.isManagingStore || state.currentStoreId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No Store Selected',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please select a store to manage orders',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to a store selection page or show a dialog
                      _showStoreSelectionDialog(context);
                    },
                    child: const Text('Select Store'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Managing Store: ${state.currentStoreId}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                _buildDashboardCard(
                  context,
                  title: 'Manage Orders',
                  icon: Icons.receipt_long,
                  onTap: () => context.go('/merchant/orders/${state.currentStoreId}'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<MultistoreIntegrationBloc>().add(ClearCurrentStore());
                  },
                  child: const Text('Clear Current Store Selection'),
                ),
              ],
            ),
          );
        },
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