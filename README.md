# 📦 FlutterBooking — Application de Réservation

## 📱 Description
Application mobile Flutter pour la gestion de réservations de ressources avec interface utilisateur moderne et système d'administration complet.

## ✨ Fonctionnalités principales
- **Authentification** : Connexion sécurisée avec Firebase Auth
- **Réservations** : Création, modification et annulation de réservations
- **Calendrier** : Vue calendrier interactive pour la sélection de créneaux
- **Dashboard** : Tableau de bord avec statistiques en temps réel
- **Administration** : Interface complète pour la gestion des ressources et validations
- **Notifications** : Système de notifications in-app
- **Profil utilisateur** : Gestion des informations personnelles

## 🛠️ Technologies utilisées
- **Framework** : Flutter 3.x
- **Backend** : Firebase (Firestore, Auth, Storage)
- **State Management** : Provider
- **UI/UX** : Material Design 3
- **Navigation** : Go Router

## 📁 Structure du projet
```
lib/
├── main.dart                    # Point d'entrée de l'application
├── models/                      # Modèles de données
├── services/                    # Services Firebase et API
├── views/                       # Pages et interfaces utilisateur
│   ├── home/                   # Page d'accueil et dashboard
│   ├── calendar/               # Gestion des réservations
│   ├── admin/                  # Interface d'administration
│   └── auth/                   # Authentification
└── widgets/                     # Composants réutilisables
```

## 🆕 Fichiers à remplacer / ajouter

### Nouveaux fichiers (créer)
| Chemin | Description |
|--------|-------------|
| `lib/views/home/main_shell.dart` | **NOUVEAU** — Shell avec Bottom Navigation Bar (5 onglets) |
| `lib/views/calendar/edit_reservation_page.dart` | **NOUVEAU** — Page modification d'une réservation (manquait dans le CDC) |

### Fichiers à remplacer
| Chemin | Changements |
|--------|-------------|
| `lib/main.dart` | Routes vers `MainShell` + nouvelle route `/edit_reservation` |
| `lib/views/home/home_page.dart` | Dashboard moderne avec SliverAppBar, stats cards, "Prochaines réservations" |
| `lib/views/calendar/my_reservations_page.dart` | Onglets À venir / En attente / Historique + bouton **Modifier** |
| `lib/views/admin/admin_page.dart` | 4 onglets : Dashboard / Ressources / Validation / Toutes |
| `lib/views/admin/admin_dashboard_page.dart` | Dashboard avec graphiques : barres hebdo, statuts, top ressources, récentes |

---

## ✅ Ce qui est corrigé / ajouté vs cahier des charges

### 1. Navigation (Bottom Navigation Bar)
- Avant : page Home avec liste de boutons
- Après : `NavigationBar` Material 3 avec 5 destinations permanentes
- FAB "Admin" visible uniquement pour admin/manager

### 2. Modification de réservation (CDC : "Annulation/modification possible")
- Avant : seulement annulation
- Après : bouton Modifier → `EditReservationPage` avec calendrier + créneaux
- La modification remet le statut à `pending` (besoin de re-validation)
- Notification in-app envoyée à l'utilisateur

### 3. Home Dashboard
- Gradient AppBar avec heure de la journée (Bonjour / Bon après-midi / Bonsoir)
- 3 stat cards : Ressources / En attente / Confirmées
- 3 quick actions avec couleurs distinctes
- Section "Prochaines réservations" avec vraies données Firestore

### 4. Mes réservations avec onglets
- Onglet "À venir" : confirmées dans le futur
- Onglet "En attente" : pending
- Onglet "Historique" : annulées/rejetées
- Cards avec indicateur couleur selon statut
- Boutons Modifier + Annuler sur les réservations actives

### 5. Dashboard Admin avec graphiques
- Vue d'ensemble : 6 indicateurs KPI
- Graphique barres : réservations 7 derniers jours
- Répartition statuts (progress bars)
- Top 5 ressources les plus demandées
- Liste des 5 réservations les plus récentes

---

## 🛠️ Instructions d'intégration

```bash
# 1. Copier les fichiers dans ton projet
cp main.dart lib/main.dart
cp main_shell.dart lib/views/home/main_shell.dart
cp home_page.dart lib/views/home/home_page.dart
cp my_reservations_page.dart lib/views/calendar/my_reservations_page.dart
cp edit_reservation_page.dart lib/views/calendar/edit_reservation_page.dart
cp admin_page.dart lib/views/admin/admin_page.dart
cp admin_dashboard_page.dart lib/views/admin/admin_dashboard_page.dart

# 2. Vérifier les imports dans main.dart
# → Supprimer les imports des anciennes pages non utilisées
#   (calendar_page, my_reservations_page sont maintenant dans MainShell)

# 3. Hot restart
flutter run
```

## ⚠️ Notes importantes

- `CalendarPage`, `ProfilePage`, `NotificationsPage` et `ResourcesPage` **sont maintenant dans le MainShell** (bottom nav), pas besoin de les garder dans les routes sauf pour la navigation directe.
- La route `/notifications` reste accessible via l'icône cloche dans la AppBar de Home.
- L'`AuthWrapper` redirige maintenant vers `MainShell` au lieu de `HomePage`.
