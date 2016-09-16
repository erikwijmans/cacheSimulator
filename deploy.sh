#!/bin/bash

git add .
git commit
git push origin master
ssh aws "cd cacheSimulator && git pull && sudo restart cacheSim && sudo service nginx restart"

# cd ~/erikwijmans.github.io/cache
# cp -r ~/cacheSimulator/public/* .
# git add .
# git commit -m "Deploying"
# git push origin master