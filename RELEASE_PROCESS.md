# 🚀 Processus de Création de Release pour arch-shell

Ce document décrit le processus complet pour créer et publier une nouvelle version d'arch-shell sur GitHub.

## 📋 Prérequis

- [ ] Accès en écriture au dépôt GitHub
- [ ] Git configuré avec vos identifiants
- [ ] GitHub CLI installé (optionnel mais recommandé)
- [ ] Tous les changements fusionnés dans la branche `main`

## 🔄 Étapes du Processus de Release

### 1. 📝 Préparation

#### Vérification des changements
```bash
# Vérifier l'état du dépôt
git status
git log --oneline HEAD~10..HEAD

# S'assurer d'être sur main et à jour
git checkout main
git pull origin main
```

#### Mise à jour du PKGBUILD
```bash
# Éditer le fichier pkgbuild/PKGBUILD
vim pkgbuild/PKGBUILD

# Mettre à jour :
# - pkgver=X.Y.Z (nouvelle version)
# - pkgrel=1 (remettre à 1 pour une nouvelle version)
```

#### Mise à jour de la documentation
- [ ] Vérifier que le README.md est à jour
- [ ] Mettre à jour les exemples si nécessaire
- [ ] Vérifier les liens de badges

### 2. 🏷️ Création du Tag et de la Release

#### Via l'interface GitHub (Recommandé)

1. **Aller sur GitHub** : Accédez à votre dépôt sur GitHub
2. **Cliquer sur "Releases"** : Dans l'onglet principal du dépôt
3. **"Draft a new release"** : Bouton vert en haut à droite
4. **Remplir les informations** :
   - **Tag version** : `v1.0.0` (format sémantique)
   - **Release title** : `arch-shell v1.0.0`
   - **Description** : Voir template ci-dessous

#### Template de Description de Release

```markdown
## 🎉 arch-shell v1.0.0

### ✨ Nouvelles fonctionnalités
- Ajout de la fonctionnalité X
- Amélioration de Y
- Support pour Z

### 🐛 Corrections de bugs
- Correction du problème #123
- Résolution de l'erreur ABC

### 🔧 Améliorations
- Optimisation des performances
- Amélioration de l'interface utilisateur

### 📦 Installation

#### Via AUR
\`\`\`bash
yay -S arch-shell
\`\`\`

#### Installation manuelle
\`\`\`bash
wget https://github.com/ArchimedeOS/arch-shell/releases/download/v1.0.0/arch-shell-1.0.0.tar.gz
tar -xzf arch-shell-1.0.0.tar.gz
cd arch-shell-1.0.0
sudo cp arch-shell.sh /usr/local/bin/arch-shell
sudo chmod +x /usr/local/bin/arch-shell
\`\`\`

### 📋 Changelog complet
Voir : [CHANGELOG.md](CHANGELOG.md)

---
**Note** : Cette version nécessite `devtools` >= 20230625
```

#### Via GitHub CLI (Alternative)

```bash
# Créer un tag local
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Créer la release avec GitHub CLI
gh release create v1.0.0 \
  --title "arch-shell v1.0.0" \
  --notes-file release-notes.md \
  --draft  # Retirer --draft pour publier immédiatement
```

### 3. 📦 Post-Release

#### Mise à jour du package AUR

```bash
# Cloner ou mettre à jour le dépôt AUR
git clone ssh://aur@aur.archlinux.org/arch-shell.git aur-arch-shell
cd aur-arch-shell

# Copier le nouveau PKGBUILD
cp ../pkgbuild/PKGBUILD .

# Calculer le nouveau checksum
updpkgsums

# Générer .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# Tester la construction
makepkg -si

# Publier sur AUR
git add PKGBUILD .SRCINFO
git commit -m "Update to version 1.0.0"
git push origin master
```

#### Communication

- [ ] Annoncer la release sur les réseaux sociaux
- [ ] Notifier les utilisateurs dans les forums appropriés
- [ ] Mettre à jour la documentation sur le site web (si applicable)

## 🔄 Processus de Hotfix

Pour les corrections urgentes :

```bash
# Créer une branche hotfix
git checkout -b hotfix/v1.0.1 v1.0.0

# Appliquer la correction
# ... faire les changements nécessaires ...

# Commit et tag
git commit -am "Fix critical issue #456"
git tag v1.0.1

# Merger dans main
git checkout main
git merge hotfix/v1.0.1

# Push tout
git push origin main
git push origin v1.0.1
git push origin hotfix/v1.0.1

# Créer la release sur GitHub
gh release create v1.0.1 --title "arch-shell v1.0.1 (Hotfix)" --notes "Correction critique du problème #456"
```

## 📋 Checklist de Release

### Avant la Release
- [ ] Tous les tests passent
- [ ] Documentation mise à jour
- [ ] CHANGELOG.md mis à jour
- [ ] Version dans PKGBUILD mise à jour
- [ ] Pas de TODO ou FIXME dans le code principal

### Pendant la Release
- [ ] Tag créé avec le bon format (v1.0.0)
- [ ] Release notes complètes et claires
- [ ] Assets ajoutés si nécessaire
- [ ] Release publiée (pas en draft)

### Après la Release
- [ ] Package AUR mis à jour
- [ ] Release annoncée
- [ ] Branche main mise à jour avec le tag
- [ ] Prochaine version planifiée

## 🛠️ Outils Utiles

### Scripts d'Automatisation

Créer un script `release.sh` :
```bash
#!/bin/bash
VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

# Mise à jour du PKGBUILD
sed -i "s/pkgver=.*/pkgver=$VERSION/" pkgbuild/PKGBUILD
sed -i "s/pkgrel=.*/pkgrel=1/" pkgbuild/PKGBUILD

# Commit et tag
git add pkgbuild/PKGBUILD
git commit -m "Bump version to $VERSION"
git tag -a "v$VERSION" -m "Release version $VERSION"

echo "Release v$VERSION ready! Push with:"
echo "git push origin main && git push origin v$VERSION"
```

### GitHub Actions (Optionnel)

Créer `.github/workflows/release.yml` pour automatiser certaines tâches :
```yaml
name: Release
on:
  release:
    types: [published]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Validate PKGBUILD
      run: |
        # Ajouter des validations ici
        echo "Validating release..."
```

## 📚 Ressources

- [Guide GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Semantic Versioning](https://semver.org/)
- [AUR Package Guidelines](https://wiki.archlinux.org/title/AUR_submission_guidelines)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
