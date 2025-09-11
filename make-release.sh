#!/bin/bash

VERSION=${1:-"v1.0.0"}
SCRIPT_NAME="arch-shell"

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Exemple: $0 v1.0.0"
    exit 1
fi

echo "Création de la release $VERSION"

echo "Récupération des PRs depuis la dernière release..."
LAST_RELEASE=$(gh release list --limit 1 --exclude-pre-releases --json tagName --jq '.[0].tagName' 2>/dev/null || echo "")

if [ -n "$LAST_RELEASE" ] && [ "$LAST_RELEASE" != "$VERSION" ]; then
    echo "   Dernière release: $LAST_RELEASE"
    
    RELEASE_DATE=$(gh release view $LAST_RELEASE --json publishedAt --jq '.publishedAt')
    
    if [ -n "$RELEASE_DATE" ]; then
        PRS=$(gh pr list --state merged --json number,title,mergedAt | jq -r --arg date "$RELEASE_DATE" '
            map(select(.mergedAt > $date)) | 
            sort_by(.mergedAt) | 
            reverse | 
            .[] | 
            "- #\(.number): \(.title)"'
        )
    else
        echo "   Impossible de récupérer la date de release"
        PRS=""
    fi
else
    echo "   Aucune release précédente trouvée"
    PRS=$(gh pr list --state merged --limit 10 --json number,title --jq '.[] | "- #\(.number): \(.title)"' 2>/dev/null || echo "")
fi

echo "Création des archives..."
tar -czf "${SCRIPT_NAME}-${VERSION}.tar.gz" "$SCRIPT_NAME"
zip "${SCRIPT_NAME}-${VERSION}.zip" "$SCRIPT_NAME"

RELEASE_NOTES="**Release ${VERSION}**

Nouvelle version stable d'arch-shell."

if [ -n "$PRS" ]; then
    RELEASE_NOTES="$RELEASE_NOTES

## Pull Requests mergées
$PRS"
fi

RELEASE_NOTES="$RELEASE_NOTES

## Installation

### Installation rapide
\`\`\`bash
curl -L -o arch-shell https://github.com/0xbbuddha/arch-shell/releases/download/${VERSION}/arch-shell
sudo mv arch-shell /usr/local/bin/arch-shell && sudo chmod +x /usr/local/bin/arch-shell
\`\`\`

### Via AUR
\`\`\`bash
yay -S arch-shell
\`\`\`"

echo "Création de la release GitHub..."
gh release create "$VERSION" \
  "${SCRIPT_NAME}-${VERSION}.tar.gz" \
  "${SCRIPT_NAME}-${VERSION}.zip" \
  "$SCRIPT_NAME" \
  --title "${SCRIPT_NAME} ${VERSION}" \
  --notes "$RELEASE_NOTES"

echo "Nettoyage..."
rm "${SCRIPT_NAME}-${VERSION}.tar.gz" "${SCRIPT_NAME}-${VERSION}.zip"

echo "Release créée: https://github.com/0xbbuddha/arch-shell/releases/tag/${VERSION}"