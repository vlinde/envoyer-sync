#!/bin/bash

# Directory containing git files
GIT_DIR="$1/git_files"
# The branch to switch to and merge changes into
BRANCH_NAME="$2"
# Teams webhook URL
TEAMS_WEBHOOK_URL="$3"

# Navigate to the git directory
cd "$GIT_DIR"

# Ensure there are no changes
git stash
git stash list
git stash drop

# Switch to the specified branch
git checkout "$BRANCH_NAME"

# Go to the main folder
cd ../

# Copy the translations from the current live version
cp -r ./current/resources/lang/ ./git_files/resources/

# Go back to the git directory
cd ./git_files

# Stage the changes
git add .

# Commit the changes
git commit -m 'Translates from online'

# Fetch the latest changes from the remote without merging them
git fetch origin "$BRANCH_NAME"

# Test merge without committing to detect conflicts
git merge --no-commit --no-ff origin/"$BRANCH_NAME"
if [ $? -ne 0 ]; then
    # Merge conflict detected, prepare message
    CONFLICTS=$(git diff --name-only --diff-filter=U)
    MESSAGE="Merge conflicts detected in the following files:\n$CONFLICTS"

    # Send the conflicts to the Teams webhook
    curl -H "Content-Type: application/json" -d "{\"text\": \"${MESSAGE}\"}" "$TEAMS_WEBHOOK_URL"

    # Abort the merge
    git merge --abort

    echo "Merge conflicts detected and reported. Aborting script."
    exit 1
else
    # Reset merge if no conflicts to maintain clean state
    git reset --merge

    # Ensure local branch is up to date with remote
    git pull --rebase origin "$BRANCH_NAME"
    git push origin "$BRANCH_NAME"
fi
