# Système de Gestion de Stock

## Description
Application web de gestion de stock développée avec ASP.NET Core MVC pour la gestion complète d'un café-restaurant.

## Fonctionnalités principales
- **Gestion des produits** : Ajout, modification, suppression des produits avec suivi des stocks
- **Gestion des fournisseurs** : Base de données complète des fournisseurs et leurs commerciaux
- **Gestion des catégories** : Classification des produits par catégories
- **Suivi des mouvements de stock** : Historique complet des entrées et sorties
- **Gestion des commandes** : Commandes d'achat avec suivi des livraisons
- **Système d'alertes** : Notifications automatiques pour les stocks faibles
- **Gestion des employés** : Administration des utilisateurs et leurs rôles
- **Logs d'activité** : Traçabilité complète des actions

## Technologies utilisées
- **Backend** : ASP.NET Core MVC (.NET 10)
- **ORM** : Entity Framework Core
- **Base de données** : SQL Server
- **Frontend** : Bootstrap 5, HTML5, CSS3, JavaScript
- **Authentification** : ASP.NET Core Identity

## Structure du projet
```
Gestion_Stock/
├── Controllers/     # Contrôleurs MVC
├── Models/         # Modèles de données
├── Views/          # Vues Razor
├── Data/           # Contexte de base de données
├── Migrations/     # Migrations Entity Framework
└── wwwroot/        # Fichiers statiques
```

## Installation et configuration
1. **Prérequis** : .NET 10 SDK, SQL Server
2. Cloner le repository : `git clone [url]`
3. Configurer la chaîne de connexion dans `appsettings.json`
4. Exécuter les migrations : `dotnet ef database update`
5. Lancer l'application : `dotnet run`

## Utilisation
L'application sera accessible sur `https://localhost:5001` après le démarrage.