#!/bin/bash

git add .
git commit -m "xfer"
git push origin master
ssh aws "cd cacheSimulator && git pull && sudo apachectl restart"