# Android App Factory

Template Android Kotlin/Compose + GitHub Actions pour créer, tester et publier des applications sans compiler sur le téléphone.

## Ce que ça fait

- `CI` : lint, tests unitaires et APK debug à chaque push, avec artifacts téléchargeables.
- `Release` : APK release signé et GitHub Release sur un tag `v*`.
- `UI Smoke` : test Compose sur émulateur + capture d’écran, à la demande ou chaque nuit.
- `harness` : commandes locales standardisées.
- `scripts/new-app.sh` : crée un nouveau repo à partir du template, configure les secrets de signature et pousse le premier commit.

## Démarrage rapide

```bash
./scripts/doctor.sh
./harness check
```

Sur Termux, préférer GitHub Actions pour les builds longs :

```bash
gh workflow run ci.yml
gh run watch
gh run download <run-id> -n app-debug -D artifacts
```

## Créer une application

```bash
./scripts/new-app.sh "Mon App" com.example.monapp
```

Options :

- `VISIBILITY=public ./scripts/new-app.sh ...` pour un repo public.
- `GH_OWNER=<compte> ./scripts/new-app.sh ...` pour un autre compte.

Le script copie le template, renomme le package et l'application, crée le repo GitHub, configure les secrets de signature et pousse sur `main`.

Les scripts et `harness` utilisent un shebang Termux. Sur Linux, lancer avec `bash`.

## Signature

Le keystore local se trouve dans `~/.android-app-factory/` et n'est jamais commité.

- `release.jks` : clé de signature stable.
- `keystore.properties` : mots de passe et alias.
- Secrets GitHub : `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.

Sauvegarde le dossier `~/.android-app-factory/` : sans lui, les mises à jour signées seront impossibles.

## Publier une version

```bash
git tag v1.0.0
git push origin v1.0.0
```

Le workflow `Release` construit l'APK signé, vérifie la signature et crée la release GitHub.

## Structure

- `app/` : application Compose minimale.
- `.github/workflows/` : CI, release, UI smoke.
- `harness` : commandes `check`, `build`, `test`, `lint`, `ui`, `release`.
- `scripts/` : création d'app et configuration des secrets.
- `AGENTS.md` : instructions pour opencode.

## Exemple validé

- Usine : https://github.com/kennydelareunion-hue/android-app-factory
- App générée : https://github.com/kennydelareunion-hue/factory-demo
- Release signée : https://github.com/kennydelareunion-hue/factory-demo/releases/tag/v0.1.1
- Validation : `v0.1.0` et `v0.1.1` ont le même certificat, `versionCode` 1 puis 2.
- UI smoke + capture : onglet Actions du repo généré, workflow `UI Smoke`.
