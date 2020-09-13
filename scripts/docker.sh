#!/bin/bash

apt remove docker docker-engine docker.io containerd runc -y

apt update

apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# Ubuntu
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y

# Debian
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

apt update

apt install docker-ce docker-ce-cli containerd.io -y

