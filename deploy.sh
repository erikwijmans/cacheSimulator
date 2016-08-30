#!/bin/bash

git commit -a
git push origin master
ssh aws "cd cacheSimulator && git pull && sudo apachectl restart"
