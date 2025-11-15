import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/admin/store_management/admin_store_bloc.dart';
import '../../bloc/admin/store_management/admin_store_event.dart';
import '../../bloc/admin/store_management/admin_store_state.dart';
import '../../models/store/store_model.dart';

class AdminStoreListPage extends StatelessWidget {
  const AdminStoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/admin/stores/add');
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => AdminStoreBloc()..add(const LoadAdminStores()),
        child: BlocBuilder<AdminStoreBloc, AdminStoreState>(
          builder: (context, state) {
            if (state.status == AdminStoreStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == AdminStoreStatus.success) {
              if (state.stores.isEmpty) {
                return const Center(child: Text('No stores found.'));
              }
              return ListView.builder(
                itemCount: state.stores.length,
                itemBuilder: (context, index) {
                  final store = state.stores[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(store.name),
                      subtitle: Text('${store.address}, ${store.city}, ${store.state} ${store.postalCode}, ${store.country}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // context.go('/admin/stores/edit/${store.id}', extra: store);
                              // For simplicity, not implementing editing yet
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _confirmDelete(context, store);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to store details if needed
                        // context.go('/admin/stores/${store.id}', extra: store);
                      },
                    ),
                  );
                },
              );
            } else if (state.status == AdminStoreStatus.failure) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            return const Center(child: Text('Press the + button to add a store.'));
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Store store) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Store'),
          content: Text('Are you sure you want to delete store "${store.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // For now, show error since API doesn't support delete
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete store endpoint not available in API')),
                );
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}