# 📅 Booky — FlutterBooking

Application mobile Flutter de réservation de ressources (salles, véhicules, matériels) avec gestion des rôles, calendrier interactif et notifications en temps réel.

---

## 🚀 Fonctionnalités

### Authentification & Profil
- Connexion / Inscription avec Firebase Auth
- Gestion des rôles : **utilisateur**, **manager**, **admin**
- Page profil éditable (nom, email, mot de passe)
- Option "Se souvenir de moi"

### Catalogue de ressources
- Liste des ressources avec filtres par catégorie
- Affichage : image, nom, description, capacité
- CRUD complet côté admin (ajout, modification, suppression)

### Réservation
- Vue calendrier des créneaux disponibles (`table_calendar`)
- Sélection d'un jour et d'un créneau horaire
- Vérification des conflits en temps réel
- Validation par un manager/admin
- Annulation possible par l'utilisateur

### Notifications in-app
- Confirmation de réservation
- Validation / Rejet par un admin
- Badge de notifications non lues en temps réel

### Administration
- Tableau de bord avec statistiques temps réel
- Gestion des ressources (CRUD)
- Gestion et validation des réservations
- Vue des réservations par statut

---

## 🏗️ Architecture

```
lib/
├── models/
│   ├── user_model.dart          # Modèle utilisateur avec rôles
│   ├── resource_model.dart      # Modèle ressource
│   └── reservation_model.dart   # Modèle réservation avec helpers
├── services/
│   ├── auth_service.dart        # Firebase Auth + Firestore users
│   ├── reservation_service.dart # CRUD réservations + détection conflits
│   ├── notification_service.dart# Notifications Firestore
│   └── preferences_service.dart # SharedPreferences (remember me)
├── providers/
│   ├── auth_provider.dart       # État utilisateur connecté
│   ├── resource_provider.dart   # Liste ressources + filtres
│   └── calendar_provider.dart   # État calendrier + réservations
├── views/
│   ├── auth/                    # Login, Signup
│   ├── home/                    # Page d'accueil
│   ├── resources/               # Liste et détail des ressources
│   ├── calendar/                # Booking, agenda, mes réservations
│   ├── admin/                   # Dashboard, ressources, validations
│   ├── profile/                 # Page profil éditable
│   └── notifications/           # Liste des notifications
├── widgets/
│   ├── calendar_widget.dart     # Widget calendrier réutilisable
│   ├── reservation_modal.dart   # Modal détail réservation
│   └── resource_card.dart       # Carte ressource
└── main.dart                    # Point d'entrée + MultiProvider + routes
```

---

## 🛠️ Stack technique

| Technologie | Usage |
|---|---|
| Flutter | Framework mobile |
| Firebase Auth | Authentification |
| Cloud Firestore | Base de données temps réel |
| Provider | Gestion d'état |
| table_calendar | Affichage calendrier |
| shared_preferences | Persistance locale |
| intl | Formatage dates (fr_FR) |

---

## ⚙️ Installation

### Prérequis
- Flutter SDK ≥ 3.9
- Compte Firebase avec projet configuré

### Étapes

```bash
# 1. Cloner le projet
git clone https://github.com/votre-username/flutter_booking.git
cd flutter_booking

# 2. Installer les dépendances
flutter pub get

# 3. Configurer Firebase
# Placer le fichier google-services.json dans android/app/
# Placer GoogleService-Info.plist dans ios/Runner/

# 4. Lancer l'application
flutter run
```

---

## 🔥 Configuration Firestore

### Collections requises

**users**
```json
{
  "name": "string",
  "email": "string",
  "role": "user | manager | admin",
  "createdAt": "timestamp"
}
```

**resources**
```json
{
  "name": "string",
  "description": "string",
  "image": "string",
  "capacity": "number",
  "category": "string"
}
```

**reservations**
```json
{
  "resourceId": "string",
  "userId": "string",
  "userName": "string",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "status": "pending | confirmed | cancelled | rejected",
  "notes": "string",
  "createdAt": "timestamp"
}
```

**notifications**
```json
{
  "userId": "string",
  "title": "string",
  "message": "string",
  "type": "reservation | validation | cancellation",
  "reservationId": "string",
  "isRead": "boolean",
  "createdAt": "timestamp"
}
```

### Index Firestore requis
Dans la console Firebase → Firestore → Index, créer :
- Collection `notifications` : `userId` (ASC) + `createdAt` (DESC)

---

## 👥 Rôles utilisateurs

| Rôle | Accès |
|---|---|
| **user** | Voir les ressources, créer/annuler ses réservations |
| **manager** | + Valider/rejeter les réservations |
| **admin** | + CRUD ressources, voir toutes les réservations, dashboard |

---

## 📊 Critères de validation

| Critère | Statut |
|---|---|
| UI claire et responsive | ✅ |
| Auth + rôles | ✅ |
| Catalogue ressources + CRUD admin | ✅ |
| Calendrier + réservation | ✅ |
| Détection des conflits | ✅ |
| Validation manager | ✅ |
| Notifications in-app | ✅ |
| Dashboard admin | ✅ |
| Documentation README | ✅ |

---

## 👨‍💻 Auteur

Projet réalisé dans le cadre du cours **SUP4 DEV — Projet Flutter 03**.
