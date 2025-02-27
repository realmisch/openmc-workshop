###############################################################################
#       DAGMC + OPENMC + ENDF-VIII.0 INSTALL SCRIPT
#       Created by Alex Nellis
#       Feb 27, 2025
#       %Working with Ubuntu 24.04
###############################################################################

#Create Directories for install
cd $HOME
mkdir dagmc_bld && cd dagmc_bld

#Install Dependencies
sudo apt-get update
sudo apt-get install g++ python3 cmake libeigen3-dev libhdf5-dev libtool libblas-dev liblapack-dev libpng-dev -y

#Install MOAB
mkdir -p MOAB/bld && cd MOAB
git clone https://bitbucket.org/fathomteam/moab
cd moab
git checkout master
autoreconf -fi

cd ..
ln -s moab src
cd bld
../src/configure --enable-optimize --enable-shared --disable-debug --with-hdf5=/usr/lib/x86_64-linux-gnu/hdf5/serial --prefix=$HOME/dagmc_bld/MOAB
make -j4
make -j4 check
make -j4 install

#Export MOAB Enironment Variables
export PATH=$PATH:$HOME/dagmc_bld/MOAB/bin
echo "export PATH=$PATH:$HOME/dagmc_bld/MOAB/bin" >> $HOME/.bashrc
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/dagmc_bld/MOAB/lib
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/dagmc_bld/MOAB/lib" >> $HOME/.bashrc

#Install DAGMC
cd $HOME/dagmc_bld
mkdir DAGMC && cd DAGMC
git clone https://github.com/svalinn/DAGMC
cd DAGMC
git checkout develop
git submodule update --init

cd $HOME/dagmc_bld/DAGMC
ln -s DAGMC src
mkdir bld && cd bld

INSTALL_PATH=$HOME/dagmc_bld/DAGMC
cmake ../src -DMOAB_DIR=$HOME/dagmc_bld/MOAB -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH
make -j4
make -j4 install

#Export DAGMC Environment Variables
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/dagmc_bld/dagmc/lib
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/dagmc_bld/dagmc/lib" >> $HOME/.bashrc

cd $HOME/dagmc_bld/
#Get OpenMC source code
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
cd openmc
git checkout master

#Begin OpenMC Build and installing Python package libopenmc
mkdir build

cd build
cmake -DOPENMC_USE_DAGMC=on -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DDAGMC_DIR=$INSTALL_PATH/bld ..
make -j4
make -j4 install
cd ../
python -m pip install .

#Get XS HDF5 library
cd ../
FILE_NAME="xslib.tar.xz"
wget https://anl.box.com/shared/static/uhbxlrx7hvxqw27psymfbhi7bx7s6u6a.xz -O $FILE_NAME
FILE_SIZE=$(du -b $FILE_NAME | cut -f1) 
tar -xJf $FILE_NAME --checkpoint=1000 --checkpoint-action=echo='%{}T (13GiB Total)%{0}*' --checkpoint-action='exec=echo "\e[2A\e[K"'

#Export Environment Variables
export OPENMC_CROSS_SECTIONS=$HOME/dagmc_bld/endfb-viii.0-hdf5/cross_sections.xml
echo 'export OPENMC_CROSS_SECTIONS=$HOME/dagmc_bld/endfb-viii.0-hdf5/cross_sections.xml' >> ~/.bashrc
rm -rf xslib.tar.xz
export PATH="$HOME/dagmc_bld/openmc/release/bin:$PATH"
echo 'export PATH="$HOME/dagmc_bld/openmc/release/bin:$PATH"' >> ~/.bashrc


