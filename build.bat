cmake -Dlaslib_DIR="C:\Users\ravi\git\geoflow-bundle\build\vcpkg_installed\x64-windows\share\lastools\LASlib" -DCMAKE_TOOLCHAIN_FILE="C:\Users\ravi\git\vcpkg\scripts\buildsystems\vcpkg.cmake" -DVCPKG_TARGET_TRIPLET="x64-windows" -DGFP_WITH_LOD2=OFF ..

cmake --build . --parallel 10 --config Release

cpack -C Release --verbose