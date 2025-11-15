import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/admin/stock_management/admin_stock_bloc.dart';
import '../../bloc/admin/stock_management/admin_stock_event.dart';
import '../../bloc/admin/stock_management/admin_stock_state.dart';
import '../../models/stock/stock_model.dart';

class AdminStockListPage extends StatelessWidget {
  const AdminStockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/admin/stock/add');
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => AdminStockBloc()..add(const LoadAdminStocks()),
        child: BlocBuilder<AdminStockBloc, AdminStockState>(
          builder: (context, state) {
            if (state.status == AdminStockStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == AdminStockStatus.success) {
              if (state.stocks.isEmpty) {
                return const Center(child: Text('No stock entries found.'));
              }
              return ListView.builder(
                itemCount: state.stocks.length,
                itemBuilder: (context, index) {
                  final stock = state.stocks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text('Product ID: ${stock.productId}'),
                      subtitle: Text('Store ID: ${stock.storeId} - Quantity: ${stock.totalQuantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // context.go('/admin/stock/edit/${stock.id}', extra: stock);
                              // For simplicity, not implementing editing yet
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _confirmDelete(context, stock);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to stock details if needed
                        // context.go('/admin/stock/${stock.id}', extra: stock);
                      },
                    ),
                  );
                },
              );
            } else if (state.status == AdminStockStatus.failure) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            return const Center(child: Text('Press the + button to add stock.'));
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Stock stock) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Stock'),
          content: Text('Are you sure you want to delete stock entry for Product ID "${stock.productId}" in Store ID "${stock.storeId}"?'),
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
                  const SnackBar(content: Text('Delete stock endpoint not available in API')),
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