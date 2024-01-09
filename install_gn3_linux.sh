sudo add-apt-repository ppa:gns3/ppa -y
sudo apt update -y                                
sudo apt install gns3-gui gns3-server -y
sudo dpkg --add-architecture i386 -y
sudo apt update -y
sudo apt install gns3-iou -y
sudo apt-get -y --no-install-recommends install curl apt-transport-https ca-certificates software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y
sudo apt install docker docker-compose -y
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
sudo usermod -aG wireshark $USER
sudo usermod -aG docker $USER

