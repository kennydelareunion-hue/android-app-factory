# AGENTS.md

## Contexte

Template Android Kotlin + Jetpack Compose, optimisé pour Termux + GitHub Actions.

## Commandes

- `./harness check` : lint + tests unitaires + APK debug.
- `./harness build` : APK debug.
- `./harness test` : tests unitaires.
- `./harness lint` : lint Android.
- `./harness ui` : tests instrumentés sur émulateur.
- `./harness release` : APK release.
- `./harness clean` : nettoyage Gradle.

## Règles

- Ne jamais commiter de keystore, mot de passe ou `local.properties`.
- Utiliser GitHub Actions pour les builds longs ; Termux sert à éditer et pousser.
- Toujours lancer `./harness check` avant un commit si l'environnement local le permet.
- Garder les tests UI basés sur des assertions, et utiliser `UI Smoke` pour la capture `home.png`.
- Vérifier `gh run list` et `gh run view --log-failed` en cas d'échec CI.

## Version et release

- `versionCode` : `VERSION_CODE` ou `1`.
- `versionName` : `VERSION_NAME` ou `0.1.0`.
- Release : tag `vX.Y.Z` puis `git push origin vX.Y.Z`.
- Les secrets de signature sont configurés par `scripts/new-app.sh` ou `scripts/setup-secrets.sh`.

## Création d'une app

```bash
./scripts/new-app.sh "Nom" com.example.nom
```

Le script renomme le package, le nom affiché, la classe de thème et le projet Gradle.
