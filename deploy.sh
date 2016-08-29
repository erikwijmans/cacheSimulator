#!/bin/bash

git commit -a
git push origin master
ssh aws "cd cacheSimulator && git pull && sudo apachectl restart"

cp -r public/* /Users/erikwijmans/erikwijmans.github.io/cache/.
cd /Users/erikwijmans/erikwijmans.github.io/cache
git commit -am "Deploying"
git push origin master