// lib/views/resources/resource_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking/models/resource_model.dart';

class ResourceDetailPage extends StatelessWidget {
  final ResourceModel resource;

  const ResourceDetailPage({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource.name),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec support assets
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: _buildImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      resource.category.toUpperCase(),
                      style: TextStyle(
                        color: _getCategoryColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resource.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.group, 'Capacité', '${resource.capacity} personnes'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/booking',
                          arguments: resource,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Réserver',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour afficher l'image
  Widget _buildImage() {
    final imagePath = resource.getImagePath();
    
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
      errorBuilder: (context, error, stackTrace) {
        // Si l'image n'existe pas, afficher une icône
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(),
                size: 80,
                color: _getCategoryColor(),
              ),
              const SizedBox(height: 8),
              Text(
                'Image non disponible',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (resource.category.toLowerCase()) {
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

  Color _getCategoryColor() {
    switch (resource.category.toLowerCase()) {
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