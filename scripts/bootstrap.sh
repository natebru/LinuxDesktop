sudo apt update
sudo apt upgrade -y

## add ssh capaabilities
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh

## Install docker from here: https://docs.docker.com/engine/install/ubuntu/