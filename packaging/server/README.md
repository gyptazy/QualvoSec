## Build packages
For building packages, simly run the following commands:

mkdir build
cd build
cmake ..
cpack -G RPM .
cpack -G DEB .
