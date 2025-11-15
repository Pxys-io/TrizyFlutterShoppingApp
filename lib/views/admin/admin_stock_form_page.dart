import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/admin/stock_management/admin_stock_bloc.dart';
import '../../bloc/admin/stock_management/admin_stock_event.dart';
import '../../models/stock/stock_model.dart';

class AdminStockFormPage extends StatefulWidget {
  final dynamic stock; // Null for create, provided for edit (though edit not supported in API)

  const AdminStockFormPage({super.key, this.stock});

  @override
  State<AdminStockFormPage> createState() => _AdminStockFormPageState();
}

class _AdminStockFormPageState extends State<AdminStockFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeIdController;
  late TextEditingController _productIdController;
  late TextEditingController _totalQuantityController;
  
  // Pricing tier controllers
  List<TextEditingController> _tierNameControllers = [];
  List<TextEditingController> _quantityPerTierControllers = [];
  List<TextEditingController> _pricePerTierControllers = [];
  List<TextEditingController> _minimumOrderControllers = [];
  List<Widget> _pricingTierWidgets = [];

  @override
  void initState() {
    super.initState();
    _storeIdController = TextEditingController(text: '');
    _productIdController = TextEditingController(text: '');
    _totalQuantityController = TextEditingController(text: '0');
    
    // Initialize with one pricing tier
    _addNewPricingTier();
  }

  @override
  void dispose() {
    _storeIdController.dispose();
    _productIdController.dispose();
    _totalQuantityController.dispose();
    
    // Dispose all pricing tier controllers
    for (var controller in _tierNameControllers) controller.dispose();
    for (var controller in _quantityPerTierControllers) controller.dispose();
    for (var controller in _pricePerTierControllers) controller.dispose();
    for (var controller in _minimumOrderControllers) controller.dispose();
    
    super.dispose();
  }
  
  void _addNewPricingTier() {
    _tierNameControllers.add(TextEditingController(text: 'Tier ${_tierNameControllers.length + 1}'));
    _quantityPerTierControllers.add(TextEditingController(text: '1'));
    _pricePerTierControllers.add(TextEditingController(text: '0.0'));
    _minimumOrderControllers.add(TextEditingController(text: '1'));
    
    setState(() {
      _pricingTierWidgets.add(_buildPricingTierWidget(_tierNameControllers.length - 1));
    });
  }
  
  void _removePricingTier(int index) {
    _tierNameControllers.removeAt(index).dispose();
    _quantityPerTierControllers.removeAt(index).dispose();
    _pricePerTierControllers.removeAt(index).dispose();
    _minimumOrderControllers.removeAt(index).dispose();
    
    setState(() {
      _pricingTierWidgets.removeAt(index);
    });
  }
  
  Widget _buildPricingTierWidget(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pricing Tier ${index + 1}'),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () => _removePricingTier(index),
                ),
              ],
            ),
            TextFormField(
              controller: _tierNameControllers[index],
              decoration: const InputDecoration(labelText: 'Tier Name'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a tier name';
                return null;
              },
            ),
            TextFormField(
              controller: _quantityPerTierControllers[index],
              decoration: const InputDecoration(labelText: 'Quantity Per Tier'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter quantity';
                if (int.tryParse(value) == null) return 'Please enter a valid number';
                return null;
              },
            ),
            TextFormField(
              controller: _pricePerTierControllers[index],
              decoration: const InputDecoration(labelText: 'Price Per Tier'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a price';
                if (double.tryParse(value) == null) return 'Please enter a valid number';
                return null;
              },
            ),
            TextFormField(
              controller: _minimumOrderControllers[index],
              decoration: const InputDecoration(labelText: 'Minimum Order'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter minimum order';
                if (int.tryParse(value) == null) return 'Please enter a valid number';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate pricing tier fields
      bool pricingTierValid = true;
      for (int i = 0; i < _tierNameControllers.length; i++) {
        if (_tierNameControllers[i].text.isEmpty ||
            _quantityPerTierControllers[i].text.isEmpty ||
            _pricePerTierControllers[i].text.isEmpty ||
            _minimumOrderControllers[i].text.isEmpty) {
          pricingTierValid = false;
          break;
        }
      }
      
      if (!pricingTierValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all pricing tier fields')),
        );
        return;
      }
      
      // Convert form data to pricing tiers
      List<PricingTier> pricingTiers = [];
      for (int i = 0; i < _tierNameControllers.length; i++) {
        pricingTiers.add(PricingTier(
          tierName: _tierNameControllers[i].text,
          quantityPerTier: int.parse(_quantityPerTierControllers[i].text),
          pricePerTier: double.parse(_pricePerTierControllers[i].text),
          minimumOrder: int.parse(_minimumOrderControllers[i].text),
        ));
      }
      
      final event = AddAdminStock(
        storeId: _storeIdController.text,
        productId: _productIdController.text,
        totalQuantity: int.parse(_totalQuantityController.text),
        pricing: pricingTiers,
      );
      
      BlocProvider.of<AdminStockBloc>(context).add(event);
      context.pop(); // Go back to the list page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _storeIdController,
                decoration: const InputDecoration(labelText: 'Store ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a store ID';
                  return null;
                },
              ),
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(labelText: 'Product ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a product ID';
                  return null;
                },
              ),
              TextFormField(
                controller: _totalQuantityController,
                decoration: const InputDecoration(labelText: 'Total Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a quantity';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Pricing Tiers', style: Theme.of(context).textTheme.titleMedium),
              ..._pricingTierWidgets,
              ElevatedButton(
                onPressed: () => _addNewPricingTier(),
                child: const Text('Add Pricing Tier'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}