cd /tmp
apt update -y && apt full upgrade -y
wget https://nmap.org/dist/zenmap-7.94-1.noarch.rpm
apt install alien -y
alien zenmap-7.94-1.noarch.rpm
wget http://archive.ubuntu.com/ubuntu/pool/universe/p/pygtk/python-gtk2_2.24.0-5.1ubuntu2_amd64.deb
wget http://azure.archive.ubuntu.com/ubuntu/pool/universe/p/pygobject-2/python-gobject-2_2.28.6-14ubuntu1_amd64.deb
wget http://security.ubuntu.com/ubuntu/pool/universe/p/pycairo/python-cairo_1.16.2-2ubuntu2_amd64.deb
dpkg -i python-gobject-2_2.28.6-14ubuntu1_amd64.deb 
dpkg -i python-cairo_1.16.2-2ubuntu2_amd64.deb
dpkg -i python-gtk2_2.24.0-5.1ubuntu2_amd64.deb 
dpkg -i zenmap-7.94-1.noarch.deb
