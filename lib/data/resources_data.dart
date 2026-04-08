// lib/data/resources_data.dart
import '../models/resource_model.dart';

class ResourcesData {
  // Liste statique de ressources pour démonstration
  static final List<ResourceModel> resources = [
    ResourceModel(
      id: '1',
      name: 'Salle de réunion A',
      description: 'Grande salle équipée d\'un vidéoprojecteur, tableau blanc et système audio. Capacité idéale pour les réunions d\'équipe.',
      image: 'assets/images/salle.jpg',
      capacity: 12,
      category: 'Salle',
    ),
    ResourceModel(
      id: '2',
      name: 'Salle de réunion B',
      description: 'Salle intime pour petites réunions, équipée d\'un écran tactile et connexion Wi-Fi haut débit.',
      image: 'assets/images/salle.jpg',
      capacity: 6,
      category: 'Salle',
    ),
    ResourceModel(
      id: '3',
      name: 'Tesla Model 3',
      description: 'Véhicule électrique haut de gamme, idéal pour les déplacements professionnels. Autonomie 500km.',
      image: 'assets/images/voiture.webp',
      capacity: 5,
      category: 'Véhicule',
    ),
    ResourceModel(
      id: '4',
      name: 'Peugeot 308',
      description: 'Véhicule confortable et économique pour vos trajets quotidiens.',
      image: 'assets/images/voiture.webp',
      capacity: 5,
      category: 'Véhicule',
    ),
    ResourceModel(
      id: '5',
      name: 'Ordinateur Dell XPS',
      description: 'PC portable haute performance avec processeur i7, 32Go RAM, idéal pour le développement.',
      image: 'assets/images/ordinateur.jpg',
      capacity: 1,
      category: 'Ordinateur',
    ),
    ResourceModel(
      id: '6',
      name: 'MacBook Pro M3',
      description: 'Ordinateur Apple dernière génération, parfait pour le design et le développement.',
      image: 'assets/images/ordinateur.jpg',
      capacity: 1,
      category: 'Ordinateur',
    ),
    ResourceModel(
      id: '7',
      name: 'Table de conférence',
      description: 'Grande table pour réunions collaboratives, avec prises électriques intégrées.',
      image: 'assets/images/table.jpg',
      capacity: 10,
      category: 'Matériel',
    ),
    ResourceModel(
      id: '8',
      name: 'Vidéoprojecteur 4K',
      description: 'Projecteur haute résolution pour présentations professionnelles.',
      image: 'assets/images/table.jpg',
      capacity: 1,
      category: 'Matériel',
    ),
    ResourceModel(
      id: '9',
      name: 'Espace coworking',
      description: 'Espace de travail partagé avec bureaux modulables et café gratuit.',
      image: 'assets/images/salle.jpg',
      capacity: 20,
      category: 'Salle',
    ),
    ResourceModel(
      id: '10',
      name: 'Audi A4',
      description: 'Berline premium pour vos déplacements professionnels importants.',
      image: 'assets/images/voiture.webp',
      capacity: 5,
      category: 'Véhicule',
    ),
  ];

  // Obtenir les ressources par catégorie
  static List<ResourceModel> getResourcesByCategory(String category) {
    if (category == 'Tous') {
      return resources;
    }
    return resources.where((r) => r.category == category).toList();
  }

  // Obtenir les catégories uniques
  static List<String> getCategories() {
    final categories = resources.map((r) => r.category).toSet().toList();
    return ['Tous', ...categories];
  }

  // Obtenir une ressource par ID
  static ResourceModel? getResourceById(String id) {
    try {
      return resources.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}