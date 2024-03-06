#!/bin/bash

cp CMakeLists.txt CMakeLists.txt.bak

mkdir packages
mkdir build
cd build
cmake ..
cpack -G DEB .
cpack -G RPM .
cp *.deb ../packages
cp *.rpm ../packages
cd ..
rm -rf build

cp CMakeLists.txt_arm64 CMakeLists.txt
mkdir build
cd build
cmake ..
cpack -G DEB .
cpack -G RPM .
cp *.deb ../packages
cp *.rpm ../packages
cd ..
rm -rf build

cp CMakeLists.txt_riscv64 CMakeLists.txt
mkdir build
cd build
cmake ..
cpack -G DEB .
cpack -G RPM .
cp *.deb ../packages
cp *.rpm ../packages
cd ..
rm -rf build

cp CMakeLists.txt.bak CMakeLists.txt
echo "Packages created. Packages can be found in directory: packages"
