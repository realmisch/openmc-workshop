###############################################################################
#       OPENMC + ENDF-VIII.0 INSTALL SCRIPT
#       Created by Alex Nellis
#       Feb 24, 2025
#       %Working with Ubuntu 24.04
###############################################################################

#Get OpenMC source code
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
cd openmc
git checkout master

#Install Dependencies not included
sudo apt update
sudo apt-get install g++ cmake libpng-dev libhdf5-dev -y

#Begin OpenMC Build and installing Python package libopenmc
mkdir build
mkdir release
install_loc=$PWD/release
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$install_loc ..
make
make install
cd ../
python -m pip install .

#Get XS HDF5 library
cd ../
FILE_NAME="xslib.tar.xz"
wget https://anl.box.com/shared/static/uhbxlrx7hvxqw27psymfbhi7bx7s6u6a.xz -O $FILE_NAME
FILE_SIZE=$(du -b $FILE_NAME | cut -f1) 
tar -xJf $FILE_NAME --checkpoint=1000 --checkpoint-action=echo='%{}T (13GiB Total)%{0}*' --checkpoint-action='exec=echo "\e[2A\e[K"'

#Export Environment Variables
export OPENMC_CROSS_SECTIONS=/workspaces/codespaces-blank/openmc-workshop/endfb-viii.0-hdf5/cross_sections.xml
echo 'export OPENMC_CROSS_SECTIONS=/workspaces/codespaces-blank/openmc-workshop/endfb-viii.0-hdf5/cross_sections.xml' >> ~/.bashrc
rm -rf xslib.tar.xz
export PATH="/workspaces/codespaces-blank/openmc-workshop/openmc/release/bin:$PATH"
echo 'export PATH="/workspaces/codespaces-blank/openmc-workshop/openmc/release/bin:$PATH"' >> ~/.bashrc

