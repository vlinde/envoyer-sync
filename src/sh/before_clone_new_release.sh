cd $1/git_files

# First I need to be sure there are not changes
git stash
git stash list
git stash drop

# Switch the branch
git checkout $2

#  Go to the main folder
cd ../

# Copy the translations from the current live version
cp -r ./current/resources/lang/ ./git_files/resources/

# Go to the git version
cd ./git_files

# Commit and push the change to git
git add .
git commit -m 'Translates from online'
git pull origin $2
git push origin $2