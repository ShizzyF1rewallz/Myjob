# Supprimer l'erreur d'index Firestore (web)

L’erreur « The query requires an index » apparaît souvent à cause du **cache du build web** (ancien JavaScript).

## 1. Rebuild complet (recommandé)

Dans le dossier du projet, exécutez :

```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

Puis dans le navigateur : **Ctrl+Shift+R** (hard refresh) ou ouvrez en **navigation privée**.

## 2. Créer l’index dans Firebase (si l’erreur continue)

1. Ouvrez le lien indiqué dans l’erreur (console Firebase → Firestore → Indexes).
2. Cliquez sur **Créer l’index**.
3. Attendez quelques minutes que l’index soit actif.

Une fois l’index créé, l’ancienne version du code pourrait aussi fonctionner.
