git submodule update --init --recursive

mkdir build-clang
cd .\build-clang\
cmake .. -DGF_BUILD_GUI=ON -DCMAKE_TOOLCHAIN_FILE=C:\Users\ravi\git\vcpkg\scripts\buildsystems\vcpkg.cmake -Dlaslib_DIR=C:\Users\ravi\git\geoflow-bundle\build\vcpkg_installed\x64-windows\share\lastools\LASlib -DPROJ_DATA_DIR=C:\Users\ravi\git\geoflow-bundle\build-clang\vcpkg_installed\x64-windows\share\proj -DCMAKE_BUILD_TYPE=Release -T ClangCL
cmake --build . --parallel 32 --config Release
cpack -C Release --verbose