#!/bin/bash

source ../../AVP/android-setup-light.sh

if [ ! -d "libmysofa" ]
then
  git clone https://github.com/hoene/libmysofa.git --depth=1 -b v1.3.3
fi

API_LEVEL=23

for ABI in armeabi-v7a arm64-v8a x86 x86_64
do
  DIST_DIR="dist-${ABI}"
  
  if [ ! -f "${DIST_DIR}/lib/libmysofa.so" ]
  then
    
    mkdir -p ${DIST_DIR}
    
    pushd ${DIST_DIR}
    ${CMAKE_PATH}/bin/cmake \
      -GNinja \
      -DANDROID_PLATFORM=${API_LEVEL} \
      -DBUILD_TESTS=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DANDROID_ABI=${ABI} \
      -DANDROID_NDK=${NDK_PATH} \
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=$(pwd)/../${DIST_DIR}/lib \
      -DCMAKE_BUILD_TYPE=Release  \
      -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake \
      -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
      -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-z,max-page-size=16384" \
      -DCMAKE_EXE_LINKER_FLAGS="-Wl,-z,max-page-size=16384" \
      -DCMAKE_MODULE_LINKER_FLAGS="-Wl,-z,max-page-size=16384" \
      ../libmysofa
	  ninja
    popd
    cp libmysofa/src/hrtf/mysofa.h ${DIST_DIR}/src
  else
    echo "Already built for ${ABI}"
  fi
done
