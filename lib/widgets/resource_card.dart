// lib/widgets/resource_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking/models/resource_model.dart';

class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onTap;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image locale
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    resource.getImagePath(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _getCategoryIcon(),
                        size: 40,
                        color: _getCategoryColor(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${resource.capacity} personnes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            resource.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getCategoryColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Flèche
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
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