#!/bin/bash

git add .
git commit
git push origin master
ssh aws "cd cacheSimulator && git pull && sudo service nginx restart"
