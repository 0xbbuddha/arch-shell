# 🏗️ Arch-Shell

Un gestionnaire d'environnements Arch Linux isolés, permettant de créer et gérer facilement des environnements de développement ou de test séparés.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=fff)](https://archlinux.org/)

## 📖 Description

Arch-Shell est un outil de gestion d'environnements Arch Linux qui utilise `arch-nspawn` pour créer des espaces de noms isolés. Il permet de :

- 🏗️ **Créer** des environnements Arch Linux propres et isolés
- 📦 **Installer** des paquets dans des environnements spécifiques
- 🚀 **Entrer** dans un environnement pour le développement ou les tests
- 📊 **Gérer** plusieurs environnements simultanément
- 🗑️ **Supprimer** facilement des environnements obsolètes

## 🔧 Prérequis

- Arch Linux ou dérivé
- `devtools` installé (`sudo pacman -S devtools`)
- Privilèges sudo
- `jq` (optionnel, pour un meilleur affichage des informations)

## 📦 Installation

### Via AUR (recommandé)

```bash
# Avec yay
yay -S arch-shell

# Avec paru
paru -S arch-shell
```

### Installation manuelle

#### Option 1 : Téléchargement direct du script
```bash
# Télécharger directement le script depuis la dernière release
curl -L -o arch-shell https://github.com/0xbbuddha/arch-shell/releases/latest/download/arch-shell
sudo mv arch-shell /usr/local/bin/arch-shell
sudo chmod +x /usr/local/bin/arch-shell
```

#### Option 2 : Archive complète
```bash
# Télécharger l'archive
wget https://github.com/0xbbuddha/arch-shell/releases/latest/download/arch-shell-v0.1.3.tar.gz
tar -xzf arch-shell-v0.1.3.tar.gz
sudo cp arch-shell /usr/local/bin/arch-shell
sudo chmod +x /usr/local/bin/arch-shell
```

#### Option 3 : Cloner le dépôt
```bash
git clone https://github.com/0xbbuddha/arch-shell.git
cd arch-shell
sudo cp arch-shell /usr/local/bin/arch-shell
sudo chmod +x /usr/local/bin/arch-shell
```

## 🚀 Utilisation

### Initialisation

Avant la première utilisation, initialisez le template de base :

```bash
arch-shell init
```

### Commandes principales

#### Créer un nouvel environnement
```bash
arch-shell create mon-env
```

#### Installer des paquets dans un environnement
```bash
arch-shell -S mon-env gcc make cmake
```

#### Entrer dans un environnement
```bash
arch-shell enter mon-env
```

#### Lister les environnements
```bash
arch-shell list
```

#### Obtenir des informations sur un environnement
```bash
arch-shell info mon-env
```

#### Supprimer un environnement
```bash
arch-shell delete mon-env
```

#### Régénérer le template de base
```bash
arch-shell regen-base
```

## 📋 Synopsis

```
arch-shell init                    # Initialise le template de base
arch-shell regen-base             # Régénère le template de base
arch-shell create <env>           # Crée un nouvel environnement
arch-shell -S <env> <pkg...>      # Installe des paquets
arch-shell enter <env>            # Entre dans un environnement
arch-shell delete <env>           # Supprime un environnement
arch-shell list                   # Liste les environnements
arch-shell info <env>             # Affiche les infos d'un environnement
```

## 🏗️ Architecture

```
~/.arch-shell/
├── store/
│   └── base-template/           # Template de base Arch Linux
├── env1/                        # Environnement utilisateur 1
│   ├── .arch-shell-env         # Métadonnées JSON
│   └── ... (système de fichiers Arch)
└── env2/                        # Environnement utilisateur 2
    ├── .arch-shell-env
    └── ... (système de fichiers Arch)
```

## 📝 Exemples d'utilisation

### Environnement de développement C++
```bash
# Créer l'environnement
arch-shell create cpp-dev

# Installer les outils de développement
arch-shell -S cpp-dev base-devel cmake gdb valgrind

# Entrer dans l'environnement
arch-shell enter cpp-dev
```

### Environnement de test avec Python
```bash
# Créer l'environnement
arch-shell create python-test

# Installer Python et ses outils
arch-shell -S python-test python python-pip python-pytest

# Entrer pour tester
arch-shell enter python-test
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créez votre branche de fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Commitez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Auteurs

- **Killian Prin-abeil** - *Développeur principal*

## 🐛 Rapporter un bug

Si vous trouvez un bug, merci de [créer une issue](https://github.com/0xbbuddha/arch-shell/issues/new) avec :

- Description du problème
- Étapes pour reproduire
- Système d'exploitation et version
- Logs d'erreur (si applicable)

## 🛠️ Développement

### Scripts de release disponibles

Ce projet inclut des scripts pour faciliter la création de releases :

- **`make-release.sh`** : Crée une release stable avec récupération automatique des PRs
- **`make-prerelease.sh`** : Crée une pré-release (alpha, beta, rc)

```bash
# Créer une release stable
./make-release.sh v1.0.0

# Créer une pré-release
./make-prerelease.sh v1.0.0-rc.1 beta