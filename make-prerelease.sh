#!/bin/bash

VERSION=${1:-"v1.0.0-beta.1"}
PRERELEASE_TYPE=${2:-"beta"}
SCRIPT_NAME="arch-shell"

if [ -z "$1" ]; then
    echo "Usage: $0 <version> [type]"
    echo "Exemples:"
    echo "  $0 v1.0.0-alpha.1 alpha"
    echo "  $0 v1.0.0-beta.1 beta"
    echo "  $0 v1.0.0-rc.1 rc"
    exit 1
fi

echo "🧪 Création de la pré-release $VERSION ($PRERELEASE_TYPE)"

# Récupérer la dernière release pour les PRs
echo "Récupération des PRs depuis la dernière release..."
LAST_RELEASE=$(gh release list --limit 1 --exclude-pre-releases --json tagName --jq '.[0].tagName' 2>/dev/null || echo "")

if [ -n "$LAST_RELEASE" ]; then
    echo "   Dernière release: $LAST_RELEASE"
    PRS=$(gh pr list --state merged --search "merged:>=$(gh release view $LAST_RELEASE --json publishedAt --jq '.publishedAt' | cut -d'T' -f1)" --json number,title,url --jq '.[] | "- #\(.number): \(.title)"' 2>/dev/null || echo "")
else
    echo "   Aucune release précédente trouvée"
    PRS=$(gh pr list --state merged --limit 10 --json number,title,url --jq '.[] | "- #\(.number): \(.title)"' 2>/dev/null || echo "")
fi

# Créer les archives
echo "Création des archives..."
tar -czf "${SCRIPT_NAME}-${VERSION}.tar.gz" "$SCRIPT_NAME"
zip "${SCRIPT_NAME}-${VERSION}.zip" "$SCRIPT_NAME" >/dev/null 2>&1

# Notes de release simples
RELEASE_NOTES="**Pré-release $PRERELEASE_TYPE ${VERSION}**

Version de test - Non recommandée pour la production"

if [ -n "$PRS" ]; then
    RELEASE_NOTES="$RELEASE_NOTES

## Pull Requests mergées
$PRS"
fi

RELEASE_NOTES="$RELEASE_NOTES

## Installation rapide
\`\`\`bash
curl -L -o arch-shell https://github.com/0xbbuddha/arch-shell/releases/download/${VERSION}/arch-shell
sudo mv arch-shell /usr/local/bin/arch-shell && sudo chmod +x /usr/local/bin/arch-shell
\`\`\`"

# Créer la pré-release
echo "Création de la pré-release GitHub..."
gh release create "$VERSION" \
  "${SCRIPT_NAME}-${VERSION}.tar.gz" \
  "${SCRIPT_NAME}-${VERSION}.zip" \
  "$SCRIPT_NAME" \
  --title "${SCRIPT_NAME} ${VERSION} (${PRERELEASE_TYPE})" \
  --notes "$RELEASE_NOTES" \
  --prerelease

# Nettoyer
rm "${SCRIPT_NAME}-${VERSION}.tar.gz" "${SCRIPT_NAME}-${VERSION}.zip"

echo "Pré-release créée: https://github.com/0xbbuddha/arch-shell/releases/tag/${VERSION}"
