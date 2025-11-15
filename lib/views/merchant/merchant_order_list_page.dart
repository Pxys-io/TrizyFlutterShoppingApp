import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/merchant/order_management/merchant_order_bloc.dart';
import '../../bloc/merchant/order_management/merchant_order_event.dart';
import '../../bloc/merchant/order_management/merchant_order_state.dart';
import '../../models/order/store_order.dart';

class MerchantOrderListPage extends StatelessWidget {
  final String storeId;

  const MerchantOrderListPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders for Store: $storeId'),
      ),
      body: BlocProvider(
        create: (context) => MerchantOrderBloc()..add(LoadMerchantOrders(storeId)),
        child: BlocBuilder<MerchantOrderBloc, MerchantOrderState>(
          builder: (context, state) {
            if (state.status == MerchantOrderStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == MerchantOrderStatus.success) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('No orders found for this store.'));
              }
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text('Order ID: ${order.orderId}'),
                      subtitle: Text('Store: ${order.storeId} | Status: ${order.state}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String newStatus) {
                          BlocProvider.of<MerchantOrderBloc>(context).add(
                            UpdateMerchantOrderStatus(storeOrderId: order.id, status: newStatus, storeId: storeId),
                          );
                        },
                        itemBuilder: (BuildContext context) {
                          return const [
                            PopupMenuItem<String>(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            PopupMenuItem<String>(
                              value: 'confirmed',
                              child: Text('Confirmed'),
                            ),
                            PopupMenuItem<String>(
                              value: 'prepared',
                              child: Text('Prepared'),
                            ),
                            PopupMenuItem<String>(
                              value: 'shipped',
                              child: Text('Shipped'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delivered',
                              child: Text('Delivered'),
                            ),
                            PopupMenuItem<String>(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                            PopupMenuItem<String>(
                              value: 'cancelled',
                              child: Text('Cancelled'),
                            ),
                          ];
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                      onTap: () {
                        // Navigate to order details if needed
                        // context.go('/merchant/orders/${order.id}', extra: order);
                      },
                    ),
                  );
                },
              );
            } else if (state.status == MerchantOrderStatus.failure) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            return const Center(child: Text('No orders to display.'));
          },
        ),
      ),
    );
  }
}