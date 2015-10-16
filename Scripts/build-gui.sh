#!/bin/sh

cd "ResponsiveMusicServer"
git fetch origin
git reset --hard origin/master
npm update
bower update
gulp build