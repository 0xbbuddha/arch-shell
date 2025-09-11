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

```bash
# Cloner le dépôt
git clone https://github.com/killian-prin/arch-shell.git
cd arch-shell

# Copier le script dans /usr/local/bin
sudo cp arch-shell.sh /usr/local/bin/arch-shell
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

Si vous trouvez un bug, merci de [créer une issue](https://github.com/killian-prin/arch-shell/issues/new) avec :

- Description du problème
- Étapes pour reproduire
- Système d'exploitation et version
- Logs d'erreur (si applicable)

## 📈 Roadmap

- [ ] Support pour d'autres distributions basées sur Arch
- [ ] Interface graphique (GTK/Qt)
- [ ] Import/export d'environnements
- [ ] Intégration avec des gestionnaires de conteneurs