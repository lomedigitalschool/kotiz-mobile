# Kotiz Mobile

Application mobile Flutter pour Kotiz - Plateforme de cagnottes collaboratives avec vérification d'identité sécurisée (v1.0.0).

Développée par Lome Digital School.

## 🚀 Fonctionnalités

### Interface mobile moderne
- Interface adaptative avec Material Design 3
- Navigation fluide avec Go Router
- Gestion d'état avec Flutter Bloc
- Authentification Firebase intégrée
- Stockage sécurisé avec Flutter Secure Storage
- Support multilingue (français/anglais) préparé

### Système d'authentification complet
- Inscription unifiée (prénom, nom, email, téléphone, mot de passe)
- Connexion utilisateur
- Authentification Firebase
- Gestion des sessions persistantes
- Vérification des emails
- Récupération de mot de passe

### Gestion des cagnottes
- Création de cagnottes avec upload d'images
- Exploration des cagnottes publiques
- Contributions aux cagnottes
- Suivi des objectifs et montants
- Partage de cagnottes via liens

### Profil utilisateur
- Informations personnelles
- Historique des contributions
- Liste des cagnottes créées
- Gestion de l'avatar

### Dashboard interactif
- Statistiques personnelles
- Liste des cagnottes actives
- Historique des transactions

### Système KYC
- Soumission de documents d'identité
- Suivi du statut de vérification
- Upload de photos (recto/verso)

## 📋 Installation

### Prérequis
- Flutter SDK (v3.8+)
- Dart SDK
- Android Studio ou Xcode
- Backend Kotiz en cours d'exécution

### Configuration

1. **Cloner le repository**
```bash
git clone https://github.com/lomedigitalschool/kotiz-mobile.git
cd kotiz-mobile
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Firebase**
   - Ajouter `google-services.json` dans `android/app/`
   - Ajouter `GoogleService-Info.plist` dans `ios/Runner/`

4. **Configurer les variables d'environnement**
   Créer un fichier `.env` dans la racine :
```env
API_BASE_URL=http://localhost:5000/api/v1
FIREBASE_API_KEY=your_firebase_api_key
```

5. **Lancer l'application**
```bash
# Développement
flutter run

# Build Android
flutter build apk

# Build iOS
flutter build ios
```

## 🏗️ Architecture

### Structure des dossiers
```
lib/
├── core/                    # Configuration et utilitaires
│   ├── network/            # Services réseau
│   ├── services/           # Services métier
│   └── utils/              # Utilitaires
├── data/                   # Modèles de données
│   ├── models/            # Classes de données
│   └── repositories/      # Accès aux données
├── logic/                  # Gestion d'état (Bloc)
├── presentation/           # Interface utilisateur
│   ├── components/        # Composants réutilisables
│   ├── views/             # Pages/screens
│   └── themes/            # Thèmes et styles
└── main.dart              # Point d'entrée
```

### Technologies utilisées
- **Flutter** - Framework UI cross-platform
- **Dart** - Langage de programmation
- **Firebase** - Authentification et base de données
- **Bloc** - Gestion d'état
- **Dio** - Client HTTP
- **Go Router** - Navigation
- **Image Picker** - Sélection d'images
- **Shared Preferences** - Stockage local
- **Flutter Secure Storage** - Stockage sécurisé

## 🔌 Intégration Backend

### Endpoints API utilisés
- `POST /auth/register-unified` - Inscription unifiée (email + téléphone + mot de passe)
- `POST /auth/login` - Connexion
- `GET /pulls` - Liste cagnottes
- `POST /pulls` - Créer cagnotte
- `POST /contributions` - Contribution
- `POST /kyc/submit` - Soumettre KYC

### Gestion des erreurs
- Intercepteurs Dio pour les erreurs HTTP
- Messages d'erreur utilisateur-friendly
- Gestion des timeouts et reconnexions

## 🔐 Sécurité

### Authentification
- JWT stocké de manière sécurisée
- Refresh automatique des tokens
- Déconnexion sécurisée

### Stockage des données
- Données sensibles chiffrées
- Stockage local sécurisé
- Nettoyage automatique des sessions expirées

## 🛠️ Développement

### Scripts disponibles
```bash
flutter pub get          # Installer dépendances
flutter run              # Lancer en développement
flutter build apk        # Build Android
flutter build ios        # Build iOS
flutter test             # Tests unitaires
flutter analyze          # Analyse du code
```

### Configuration Firebase
- Authentification utilisateur
- Base de données Firestore (optionnel)
- Stockage Firebase (optionnel)

## 🚀 Déploiement

### Android
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Stores
- **Google Play Store** : Upload du bundle
- **Apple App Store** : Upload via Xcode

## 🧪 Tests

### Tests unitaires
```bash
flutter test
```

### Tests d'intégration
```bash
flutter drive --target=test_driver/app.dart
```

## 📱 Fonctionnalités supportées

- ✅ Inscription et connexion
- ✅ Création de cagnottes
- ✅ Contributions
- ✅ Profil utilisateur
- ✅ Système KYC
- ✅ Dashboard
- ✅ Partage de cagnottes

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Équipe

Développé par **Lome Digital School**

- 📧 Contact : contact@lomedigitalschool.com
- 🌐 Site web : https://lomedigitalschool.com

---

**Kotiz Mobile** - Application mobile pour la plateforme de cagnottes collaboratives avec vérification d'identité sécurisée.
