#!/bin/bash

VERSION=${1:-"v1.0.0"}
SCRIPT_NAME="arch-shell"

echo "Création de la release $VERSION"

# Créer les archives
echo "Création des archives..."
tar -czf "${SCRIPT_NAME}-${VERSION}.tar.gz" "$SCRIPT_NAME"
zip "${SCRIPT_NAME}-${VERSION}.zip" "$SCRIPT_NAME"

# Créer la release
echo "Création de la release GitHub..."
gh release create "$VERSION" \
  "${SCRIPT_NAME}-${VERSION}.tar.gz" \
  "${SCRIPT_NAME}-${VERSION}.zip" \
  --title "${SCRIPT_NAME} ${VERSION}" \
  --notes "Release ${VERSION} du script ${SCRIPT_NAME}

Téléchargez :
- \`${SCRIPT_NAME}-${VERSION}.tar.gz\` pour Linux/macOS
- \`${SCRIPT_NAME}-${VERSION}.zip\` pour Windows/multi-plateforme"

# Nettoyer les fichiers temporaires
echo "Nettoyage..."
rm "${SCRIPT_NAME}-${VERSION}.tar.gz" "${SCRIPT_NAME}-${VERSION}.zip"

echo "Release créée avec succès !"