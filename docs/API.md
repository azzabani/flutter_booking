# Documentation API

## Vue d'ensemble
Cette documentation décrit les interactions avec Firebase utilisées dans l'application Flutter Booking.

## Firebase Services

### Authentication
```dart
// Connexion utilisateur
FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Inscription utilisateur
FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
```

### Firestore Collections

#### Users Collection
```
users/{userId}
├── email: string
├── displayName: string
├── role: string (user|admin|manager)
├── createdAt: timestamp
└── lastLogin: timestamp
```

#### Reservations Collection
```
reservations/{reservationId}
├── userId: string
├── resourceId: string
├── startTime: timestamp
├── endTime: timestamp
├── status: string (pending|confirmed|cancelled|rejected)
├── notes: string
├── createdAt: timestamp
└── updatedAt: timestamp
```

#### Resources Collection
```
resources/{resourceId}
├── name: string
├── description: string
├── capacity: number
├── isActive: boolean
├── createdAt: timestamp
└── updatedAt: timestamp
```

## Règles de Sécurité Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reservations rules
    match /reservations/{reservationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager']);
    }
    
    // Resources - read for all authenticated users
    match /resources/{resourceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager'];
    }
  }
}
```

## Modèles de Données

### User Model
```dart
class User {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;
}
```

### Reservation Model
```dart
class Reservation {
  final String id;
  final String userId;
  final String resourceId;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Resource Model
```dart
class Resource {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final bool isActive;
  final DateTime createdAt;
}
```