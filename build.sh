#!/usr/bin/env bash

[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.nvm/nvm.sh ] && source ~/.nvm/nvm.sh
if nvm --version; then
  nvm use lts/boron
else
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
  source ~/.nvm/nvm.sh
  nvm install lts/boron
  nvm use lts/boron
fi

coffee -v || npm install -g coffee-script
grunt --version || npm install -g grunt-cli
pm2 --version || npm install -g pm2

npm prune
npm install
grunt build

if [ "$1" != "production" ]; then
  grunt doc:generate
fi;
cp -R ../shared/config .

pm2 startOrGracefulReload ecosystem.json5 --env $1
pm2 save
