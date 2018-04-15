#!/usr/bin/env bash

echo "Setting up for environment: $1"

# Load required bash scripts
[ -f $HOME/.bash_aliases ] && source $HOME/.bash_aliases

export DEBIAN_FRONTEND=noninteractive
sudo add-apt-repository -y ppa:nginx/stable
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get upgrade -yq
sudo apt-get install -y nginx git build-essential htop letsencrypt
sudo apt-get autoremove && sudo apt-get clean

export LETSENCRYPT_AUTO_RENEW_SCRIPT='/etc/cron.daily/letsencrypt-renew'
echo $'#!/bin/sh\nexport DIR=/tmp/.letsencrypt && mkdir -p $DIR && /usr/bin/letsencrypt renew && rm -rf $DIR' | sudo tee --append "$LETSENCRYPT_AUTO_RENEW_SCRIPT" > /dev/null
sudo chmod +x "$LETSENCRYPT_AUTO_RENEW_SCRIPT"

export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/creationix/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && source "$NVM_DIR/nvm.sh"

echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc

nvm install lts/boron
nvm alias default lts/boron
grunt --version || npm install -g grunt-cli
pm2 --version || npm install -g pm2@latest
sudo su -c "env PATH=$PATH:$NVM_BIN pm2 startup ubuntu -u ubuntu --hp /home/ubuntu"

mkdir -p $HOME/.ssh/
[ ! -f $HOME/.ssh/id_rsa ] && ssh-keygen -t rsa -b 4096 -C "Auto Deployment Key" -f $HOME/.ssh/id_rsa -N "" -q
echo $'Host bitbucket\nHostName bitbucket.com\nUser git\nIdentityfile ~/.ssh/id_rsa\n' >> $HOME/.ssh/config
echo 'Please configure the following public key as deploy key in Bitbucket repo under Settings > Deployment Keys!'
echo '=============================================================='
ssh-keygen -f $HOME/.ssh/id_rsa -y
echo '=============================================================='
ssh-keyscan -H bitbucket.com >> $HOME/.ssh/known_hosts
ssh -q bitbucket
if [ $? -gt 0 ]; then
  echo 'Deploy key should be configured to clone the repository!'
  exit 1
fi