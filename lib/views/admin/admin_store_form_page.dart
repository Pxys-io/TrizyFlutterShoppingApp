import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/admin/store_management/admin_store_bloc.dart';
import '../../bloc/admin/store_management/admin_store_event.dart';
import '../../models/store/store_model.dart';

class AdminStoreFormPage extends StatefulWidget {
  final Store? store; // Null for create, provided for edit

  const AdminStoreFormPage({super.key, this.store});

  @override
  State<AdminStoreFormPage> createState() => _AdminStoreFormPageState();
}

class _AdminStoreFormPageState extends State<AdminStoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store?.name ?? '');
    _addressController = TextEditingController(text: widget.store?.address ?? '');
    _cityController = TextEditingController(text: widget.store?.city ?? '');
    _stateController = TextEditingController(text: widget.store?.state ?? '');
    _countryController = TextEditingController(text: widget.store?.country ?? '');
    _postalCodeController = TextEditingController(text: widget.store?.postalCode ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.store == null) {
        // Create new store
        final event = AddAdminStore(
          name: _nameController.text,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _countryController.text,
          postalCode: _postalCodeController.text,
        );
        BlocProvider.of<AdminStoreBloc>(context).add(event);
      } else {
        // For now, update is not supported as the API doesn't have this endpoint
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update store endpoint not available in API')),
        );
      }
      context.pop(); // Go back to the list page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store == null ? 'Create Store' : 'Edit Store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a store name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a state';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a country';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a postal code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.store == null ? 'Create Store' : 'Update Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}