# MyJob – Plateforme d'offres d'emploi

Application Flutter (MVC + Provider) permettant aux **recruteurs** de publier des annonces et aux **candidats** de rechercher, sauvegarder et postuler aux offres.

## Fonctionnalités

- **Authentification** : Inscription (Candidat / Recruteur), connexion, déconnexion, persistance de session, réinitialisation du mot de passe (Firebase Auth)
- **Profils** : Candidat (nom, email, téléphone, photo, CV, compétences, domaine, ville, description) ; Recruteur (entreprise, logo, description, secteur)
- **Offres** : CRUD (création, lecture, modification, suppression), recherche et filtres (titre, ville, type de contrat, domaine)
- **Candidatures** : Postuler (CV + message), suivi des statuts (En attente / Acceptée / Refusée), gestion côté recruteur (accepter, refuser, supprimer)
- **Favoris** : Ajout / suppression d’offres sauvegardées
- **API externe** : Import d’offres depuis l’API Arbeitnow (emplois internationaux), synchronisation avec Firestore
- **Tableaux de bord** : Statistiques candidat (candidatures, favoris) et recruteur (offres, candidats, acceptés/refusés)
- **UX** : Indicateurs de chargement, Snackbars, dialogues de confirmation, navigation par BottomNavBar .

## Architecture

- **MVC** : `lib/models`, `lib/views`, `lib/controllers`, `lib/services`
- **State management** : Provider
- **Base de données** : Firestore (collections : `users`, `jobs`, `applications`, `favorites`)
- **Stockage** : Firebase Storage (photos, CV, logos)

## Configuration Firebase (obligatoire)

Projet Firebase : **myjob-42033**

1. **Prérequis** : être connecté à Firebase (`firebase login` si besoin).
2. **FlutterFire** : à la racine du projet, exécuter :
   ```bash
   dart pub global activate flutterfire_cli
   ```
   Puis (en ajoutant `Pub\Cache\bin` au PATH si nécessaire) :
   ```bash
   flutterfire configure --project=myjob-42033
   ```
   Ou utiliser le script fourni (PowerShell) :
   ```powershell
   .\configurer_firebase.ps1
   ```
   Cela enregistre les apps (Android, iOS, Web, Windows) et génère `lib/firebase_options.dart`.

3. Dans la **Console Firebase** : activer **Authentication** (Email/Mot de passe), **Firestore** et **Storage**.

## Identifiants et côté « administrateur »

Il **n’y a pas de compte administrateur** ni d’identifiants prédéfinis. L’app ne gère que deux types d’utilisateurs :

- **Candidat** : cherche des offres, postule, gère favoris et candidatures.
- **Recruteur** : publie et gère des offres, consulte et traite les candidatures.

Pour tester le côté « admin » (gestion des offres et des candidatures), **inscrivez-vous comme Recruteur** (onglet Recruteur à l’inscription) avec un email et un mot de passe de votre choix. Vous pourrez ensuite vous connecter et accéder au tableau de bord recruteur (mes offres, candidatures reçues, etc.).

## Lancement

```bash
flutter pub get
flutter run
```

## Résumé

Une plateforme d’offres d’emploi permet aux recruteurs de publier des annonces et aux candidats de rechercher, sauvegarder et postuler aux offres, avec authentification, base de données en temps réel, API externe et architecture MVC.
