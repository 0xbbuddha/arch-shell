#!/bin/bash

VERSION=${1:-"v1.0.0"}
SCRIPT_NAME="arch-shell"

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Exemple: $0 v1.0.0"
    exit 1
fi

echo "Création de la release $VERSION"

clean_emojis() {
    echo "$1" | sed 's/[[:space:]]*[🎉🧪📋🔄📦🚀🧹✅✨🐛📚🔧🏗️🎨][[:space:]]*/ /g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
}

categorize_prs() {
    local prs_data="$1"
    local cleaned_prs=$(clean_emojis "$prs_data")
    local result=""

    local feat_prs=$(echo "$cleaned_prs" | grep -E "(feat|feature)" | grep -v "fix" || true)
    if [ -n "$feat_prs" ]; then
        result="$result

### New Features
$feat_prs"
    fi

    local fix_prs=$(echo "$cleaned_prs" | grep -E "(fix|bug)" || true)
    if [ -n "$fix_prs" ]; then
        result="$result

### Bug Fixes
$fix_prs"
    fi

    local docs_prs=$(echo "$cleaned_prs" | grep -E "(docs|doc)" || true)
    if [ -n "$docs_prs" ]; then
        result="$result

### Documentation
$docs_prs"
    fi

    local refactor_prs=$(echo "$cleaned_prs" | grep -E "(refactor|perf|improvement)" | grep -v -E "(feat|fix|docs)" || true)
    if [ -n "$refactor_prs" ]; then
        result="$result

### Technical Improvements
$refactor_prs"
    fi

    local ci_prs=$(echo "$cleaned_prs" | grep -E "(ci|build|chore)" || true)
    if [ -n "$ci_prs" ]; then
        result="$result

### CI/CD & Build
$ci_prs"
    fi

    echo "$result"
}

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
    CATEGORIZED_PRS=$(categorize_prs "$PRS")
    RELEASE_NOTES="$RELEASE_NOTES

## Changes$CATEGORIZED_PRS"
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