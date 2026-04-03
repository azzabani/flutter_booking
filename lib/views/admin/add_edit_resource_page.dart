// lib/views/admin/add_edit_resource_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking/models/resource_model.dart';

class AddEditResourcePage extends StatefulWidget {
  final ResourceModel? resource;

  const AddEditResourcePage({super.key, this.resource});

  @override
  State<AddEditResourcePage> createState() => _AddEditResourcePageState();
}

class _AddEditResourcePageState extends State<AddEditResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _capacityController = TextEditingController();
  String _selectedCategory = 'salle';
  bool _isLoading = false;

  final List<String> _categories = ['salle', 'véhicule', 'ordinateur', 'matériel'];

  @override
  void initState() {
    super.initState();
    if (widget.resource != null) {
      _nameController.text = widget.resource!.name;
      _descriptionController.text = widget.resource!.description;
      _imageController.text = widget.resource!.image;
      _capacityController.text = widget.resource!.capacity.toString();
      _selectedCategory = widget.resource!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image': _imageController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'category': _selectedCategory,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.resource == null) {
        // Ajouter une nouvelle ressource
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('resources').add(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ressource ajoutée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Modifier une ressource existante
        await FirebaseFirestore.instance
            .collection('resources')
            .doc(widget.resource!.id)
            .update(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ressource modifiée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource == null ? 'Ajouter une ressource' : 'Modifier la ressource'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nom
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la ressource *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Catégorie
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Capacité
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacité (nombre de personnes) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la capacité';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Image URL
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'URL de l\'image (optionnel)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                        hintText: 'https://exemple.com/image.jpg',
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveResource,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.resource == null ? 'Ajouter' : 'Modifier',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}