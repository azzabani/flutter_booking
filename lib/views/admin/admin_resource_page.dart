// lib/views/admin/admin_resource_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking/models/resource_model.dart';
import 'package:flutter_booking/views/admin/add_edit_resource_page.dart';

class AdminResourcePage extends StatefulWidget {
  const AdminResourcePage({super.key});

  @override
  State<AdminResourcePage> createState() => _AdminResourcePageState();
}

class _AdminResourcePageState extends State<AdminResourcePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedCategory = 'tous';
  final List<String> _categories = ['tous', 'salle', 'véhicule', 'ordinateur', 'matériel'];

  Future<void> _deleteResource(String resourceId, String resourceName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la ressource'),
        content: Text('Voulez-vous vraiment supprimer "$resourceName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('resources').doc(resourceId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ressource supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditResourcePage(),
            ),
          );
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.blue.shade700,
                  ),
                );
              },
            ),
          ),
          
          // Liste des ressources
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == 'tous'
                  ? _firestore.collection('resources').snapshots()
                  : _firestore
                      .collection('resources')
                      .where('category', isEqualTo: _selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final resources = snapshot.data!.docs;
                
                if (resources.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune ressource',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliquez sur le bouton + pour ajouter',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final doc = resources[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final resource = ResourceModel(
                      id: doc.id,
                      name: data['name'] ?? '',
                      description: data['description'] ?? '',
                      image: data['image'] ?? '',
                      capacity: data['capacity'] ?? 0,
                      category: data['category'] ?? 'autre',
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(resource.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(resource.category),
                            color: _getCategoryColor(resource.category),
                          ),
                        ),
                        title: Text(
                          resource.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capacité: ${resource.capacity} personnes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditResourcePage(
                                      resource: resource,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteResource(resource.id, resource.name);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salle':
        return Icons.meeting_room;
      case 'véhicule':
        return Icons.directions_car;
      case 'ordinateur':
        return Icons.computer;
      case 'matériel':
        return Icons.build;
      default:
        return Icons.inventory;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salle':
        return Colors.blue;
      case 'véhicule':
        return Colors.green;
      case 'ordinateur':
        return Colors.purple;
      case 'matériel':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}