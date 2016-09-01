#!/bin/bash

git commit -a
git push origin master
ssh aws "cd cacheSimulator && git pull && sudo service apache2 restart"
