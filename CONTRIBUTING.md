# Guide de Contribution

Merci de votre intérêt pour contribuer à Flutter Booking ! Ce guide vous aidera à comprendre comment participer au développement du projet.

## 🚀 Démarrage rapide

### Prérequis
- Flutter SDK 3.x ou plus récent
- Dart SDK ^3.9.2
- IDE recommandé : VS Code ou Android Studio
- Compte Firebase pour les tests

### Installation
```bash
# Cloner le repository
git clone https://github.com/azzabani/flutter_booking.git
cd flutter_booking

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 📝 Standards de code

### Style de code
- Suivre les conventions Dart officielles
- Utiliser `flutter format` avant chaque commit
- Respecter les règles définies dans `analysis_options.yaml`
- Préférer les guillemets simples pour les chaînes
- Utiliser des constructeurs `const` quand possible

### Structure des commits
```
type(scope): description courte

Description détaillée si nécessaire

Fixes #123
```

Types de commits :
- `feat`: nouvelle fonctionnalité
- `fix`: correction de bug
- `docs`: documentation
- `style`: formatage, style
- `refactor`: refactoring
- `test`: ajout de tests
- `config`: configuration

## 🧪 Tests

### Lancer les tests
```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

### Écrire des tests
- Chaque nouvelle fonctionnalité doit avoir des tests
- Maintenir une couverture de code > 80%
- Tester les cas d'erreur et les cas limites

## 📋 Processus de contribution

1. **Fork** le repository
2. **Créer** une branche pour votre fonctionnalité
3. **Développer** en suivant les standards
4. **Tester** votre code
5. **Commiter** avec des messages clairs
6. **Pousser** vers votre fork
7. **Créer** une Pull Request

## 🐛 Signaler des bugs

Utilisez les issues GitHub avec le template :
- Description du problème
- Étapes pour reproduire
- Comportement attendu vs actuel
- Captures d'écran si applicable
- Informations sur l'environnement

## 💡 Proposer des fonctionnalités

Avant de développer une nouvelle fonctionnalité :
1. Vérifier qu'elle n'existe pas déjà
2. Créer une issue pour discussion
3. Attendre l'approbation avant de commencer

## 📞 Contact

Pour toute question, n'hésitez pas à :
- Ouvrir une issue
- Contacter l'équipe de développement