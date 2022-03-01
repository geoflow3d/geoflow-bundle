cmake -Dlaslib_DIR="C:\Users\ravi\git\geoflow-bundle\build\vcpkg_installed\x64-windows\share\lastools\LASlib" -DCMAKE_TOOLCHAIN_FILE="C:\Users\ravi\git\vcpkg\scripts\buildsystems\vcpkg.cmake" -DVCPKG_TARGET_TRIPLET="x64-windows" -DVCPKG_ROOT=="C:\Users\ravi\git\vcpkg" -CMAKE_GENERATOR_PLATFORM=x64 ..

cmake --build . --parallel 10 --config Release

cpack -C Release --verbose