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

echo "Création de la pré-release $VERSION ($PRERELEASE_TYPE)"

categorize_prs() {
    local prs_data="$1"
    local result=""
    local categorized_prs=""
    
    local feat_prs=$(echo "$prs_data" | grep -E "^- #[0-9]+: .*(feat|feature)" | grep -v "fix" || true)
    if [ -n "$feat_prs" ]; then
        result="$result

### New Features
$feat_prs"
        categorized_prs="$categorized_prs$feat_prs"$'\n'
    fi
    
    local fix_prs=$(echo "$prs_data" | grep -E "^- #[0-9]+: .*(fix|bug)" || true)
    if [ -n "$fix_prs" ]; then
        result="$result

### Bug Fixes
$fix_prs"
        categorized_prs="$categorized_prs$fix_prs"$'\n'
    fi
    
    local docs_prs=$(echo "$prs_data" | grep -E "^- #[0-9]+: .*(docs|doc)" || true)
    if [ -n "$docs_prs" ]; then
        result="$result

### Documentation
$docs_prs"
        categorized_prs="$categorized_prs$docs_prs"$'\n'
    fi
    
    local refactor_prs=$(echo "$prs_data" | grep -E "^- #[0-9]+: .*(refactor|perf|improvement)" | grep -v -E "(feat|fix|docs)" || true)
    if [ -n "$refactor_prs" ]; then
        result="$result

### Technical Improvements
$refactor_prs"
        categorized_prs="$categorized_prs$refactor_prs"$'\n'
    fi
    
    local ci_prs=$(echo "$prs_data" | grep -E "^- #[0-9]+: .*(ci|build|chore)" || true)
    if [ -n "$ci_prs" ]; then
        result="$result

### CI/CD & Build
$ci_prs"
        categorized_prs="$categorized_prs$ci_prs"$'\n'
    fi
    
    local other_prs=""
    while IFS= read -r line; do
        if [ -n "$line" ] && ! echo "$categorized_prs" | grep -Fq "$line"; then
            other_prs="$other_prs$line"$'\n'
        fi
    done <<< "$prs_data"
    
    if [ -n "$other_prs" ] && [ "$other_prs" != $'\n' ]; then
        result="$result

### Other Changes
$other_prs"
    fi
    
    echo "$result"
}

echo "Récupération des PRs depuis la dernière release..."
LAST_RELEASE=$(gh release list --limit 1 --exclude-pre-releases --json tagName --jq '.[0].tagName' 2>/dev/null || echo "")

if [ -n "$LAST_RELEASE" ]; then
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
zip "${SCRIPT_NAME}-${VERSION}.zip" "$SCRIPT_NAME" >/dev/null 2>&1

RELEASE_NOTES="**Pré-release $PRERELEASE_TYPE ${VERSION}**

Version de test - Non recommandée pour la production"

if [ -n "$PRS" ]; then
    CATEGORIZED_PRS=$(categorize_prs "$PRS")
    RELEASE_NOTES="$RELEASE_NOTES

## Changes$CATEGORIZED_PRS"
fi

RELEASE_NOTES="$RELEASE_NOTES


\`\`\`bash
curl -L -o arch-shell https://github.com/0xbbuddha/arch-shell/releases/download/${VERSION}/arch-shell
sudo mv arch-shell /usr/local/bin/arch-shell && sudo chmod +x /usr/local/bin/arch-shell
\`\`\`"

echo "Création de la pré-release GitHub..."
gh release create "$VERSION" \
  "${SCRIPT_NAME}-${VERSION}.tar.gz" \
  "${SCRIPT_NAME}-${VERSION}.zip" \
  "$SCRIPT_NAME" \
  --title "${SCRIPT_NAME} ${VERSION} (${PRERELEASE_TYPE})" \
  --notes "$RELEASE_NOTES" \
  --prerelease

rm "${SCRIPT_NAME}-${VERSION}.tar.gz" "${SCRIPT_NAME}-${VERSION}.zip"

echo "Pré-release créée: https://github.com/0xbbuddha/arch-shell/releases/tag/${VERSION}"
