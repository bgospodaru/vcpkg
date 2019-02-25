include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebook/rocksdb
  REF v5.17.2
  SHA512 c9f9bff747d0d2c97f8adb71d6a3bd5dc206c2fc567a47d0400abac61fec7f2a386d16cda5447bcf592cca006fd6d4c5ae1a68d122e2e2a03d3ebcc002dae147
  HEAD_REF master
  PATCHES
    0001-disable-gtest.patch
    0002-only-build-one-flavor.patch
    0003-zlib-findpackage.patch
    0004-use-find-package.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/modules/Findzlib.cmake")
file(COPY
  "${CMAKE_CURRENT_LIST_DIR}/Findlz4.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/Findsnappy.cmake"
  DESTINATION "${SOURCE_PATH}/cmake/modules"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_MD_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ROCKSDB_DISABLE_INSTALL_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ROCKSDB_DISABLE_INSTALL_STATIC_LIB)

set(WITH_LZ4 OFF)
if("lz4" IN_LIST FEATURES)
  set(WITH_LZ4 ON)
endif()

set(WITH_SNAPPY OFF)
if("snappy" IN_LIST FEATURES)
  set(WITH_SNAPPY ON)
endif()

set(WITH_ZLIB OFF)
if("zlib" IN_LIST FEATURES)
  set(WITH_ZLIB ON)
endif()

set(WITH_TBB OFF)
set(ROCKSDB_IGNORE_PACKAGE_TBB TRUE)
if("tbb" IN_LIST FEATURES)
  set(WITH_TBB ON)
  set(ROCKSDB_IGNORE_PACKAGE_TBB FALSE)
endif()


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
  -DWITH_GFLAGS=0
  -DWITH_SNAPPY=${WITH_SNAPPY}
  -DWITH_LZ4=${WITH_LZ4}
  -DWITH_ZLIB=${WITH_ZLIB}
  -DWITH_TBB=${WITH_TBB}
  -DWITH_TESTS=OFF
  -DUSE_RTTI=1
  -DROCKSDB_INSTALL_ON_WINDOWS=ON
  -DFAIL_ON_WARNINGS=OFF
  -DWITH_MD_LIBRARY=${WITH_MD_LIBRARY}
  -DPORTABLE=ON
  -DCMAKE_DEBUG_POSTFIX=d
  -DROCKSDB_DISABLE_INSTALL_SHARED_LIB=${ROCKSDB_DISABLE_INSTALL_SHARED_LIB}
  -DROCKSDB_DISABLE_INSTALL_STATIC_LIB=${ROCKSDB_DISABLE_INSTALL_STATIC_LIB}
  -DCMAKE_DISABLE_FIND_PACKAGE_TBB=${ROCKSDB_IGNORE_PACKAGE_TBB}
  -DCMAKE_DISABLE_FIND_PACKAGE_NUMA=TRUE
  -DCMAKE_DISABLE_FIND_PACKAGE_gtest=TRUE
  -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/rocksdb)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.Apache DESTINATION ${CURRENT_PACKAGES_DIR}/share/rocksdb RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${SOURCE_PATH}/LICENSE.leveldb DESTINATION ${CURRENT_PACKAGES_DIR}/share/rocksdb)

vcpkg_copy_pdbs()
