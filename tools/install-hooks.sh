#!/usr/bin/env bash
# STEALTHPANDA: copy tools/git-hooks/* into .git/hooks (local to this
# clone; hooks are not part of the repository).
set -e
cd "$(dirname "$0")/.."
mkdir -p .git/hooks
cp tools/git-hooks/pre-commit .git/hooks/pre-commit
cp tools/git-hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
echo "installed: .git/hooks/pre-commit (fast invariants)"
echo "installed: .git/hooks/pre-push    (stealth regression gate)"
