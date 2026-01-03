sudo apt update
sudo apt upgrade -y

## add ssh capaabilities
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh

