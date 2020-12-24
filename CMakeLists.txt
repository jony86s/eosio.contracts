cmake_minimum_required(VERSION 3.5)

project(eosio_contracts)

set(VERSION_MAJOR 1)
set(VERSION_MINOR 9)
set(VERSION_PATCH 2)
#set(VERSION_SUFFIX rc4)

if (VERSION_SUFFIX)
   set(VERSION_FULL &quot;${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}-${VERSION_SUFFIX}&quot;)
else()
   set(VERSION_FULL &quot;${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}&quot;)
endif()

include(ExternalProject)

find_package(eosio.cdt)

message(STATUS &quot;Building eosio.contracts v${VERSION_FULL}&quot;)

set(EOSIO_CDT_VERSION_MIN &quot;1.7&quot;)
set(EOSIO_CDT_VERSION_SOFT_MAX &quot;1.7&quot;)
#set(EOSIO_CDT_VERSION_HARD_MAX &quot;&quot;)

### Check the version of eosio.cdt
set(VERSION_MATCH_ERROR_MSG &quot;&quot;)
EOSIO_CHECK_VERSION(VERSION_OUTPUT &quot;${EOSIO_CDT_VERSION}&quot;
                                   &quot;${EOSIO_CDT_VERSION_MIN}&quot;
                                   &quot;${EOSIO_CDT_VERSION_SOFT_MAX}&quot;
                                   &quot;${EOSIO_CDT_VERSION_HARD_MAX}&quot;
                                   VERSION_MATCH_ERROR_MSG)
if(VERSION_OUTPUT STREQUAL &quot;MATCH&quot;)
   message(STATUS &quot;Using eosio.cdt version ${EOSIO_CDT_VERSION}&quot;)
elseif(VERSION_OUTPUT STREQUAL &quot;WARN&quot;)
   message(WARNING &quot;Using eosio.cdt version ${EOSIO_CDT_VERSION} even though it exceeds the maximum supported version of ${EOSIO_CDT_VERSION_SOFT_MAX}; continuing with configuration, however build may fail.\nIt is recommended to use eosio.cdt version ${EOSIO_CDT_VERSION_SOFT_MAX}.x&quot;)
else() # INVALID OR MISMATCH
   message(FATAL_ERROR &quot;Found eosio.cdt version ${EOSIO_CDT_VERSION} but it does not satisfy version requirements: ${VERSION_MATCH_ERROR_MSG}\nPlease use eosio.cdt version ${EOSIO_CDT_VERSION_SOFT_MAX}.x&quot;)
endif(VERSION_OUTPUT STREQUAL &quot;MATCH&quot;)

if(CMAKE_BUILD_TYPE STREQUAL &quot;Debug&quot;)
   set(TEST_BUILD_TYPE &quot;Debug&quot;)
   set(CMAKE_BUILD_TYPE &quot;Release&quot;)
else()
   set(TEST_BUILD_TYPE ${CMAKE_BUILD_TYPE})
endif()

ExternalProject_Add(
   contracts_project
   SOURCE_DIR ${CMAKE_SOURCE_DIR}/contracts
   BINARY_DIR ${CMAKE_BINARY_DIR}/contracts
   CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=${EOSIO_CDT_ROOT}/lib/cmake/eosio.cdt/EosioWasmToolchain.cmake
   UPDATE_COMMAND &quot;&quot;
   PATCH_COMMAND &quot;&quot;
   TEST_COMMAND &quot;&quot;
   INSTALL_COMMAND &quot;&quot;
   BUILD_ALWAYS 1
)

if (APPLE)
   set(OPENSSL_ROOT &quot;/usr/local/opt/openssl&quot;)
elseif (UNIX)
   set(OPENSSL_ROOT &quot;/usr/include/openssl&quot;)
endif()
set(SECP256K1_ROOT &quot;/usr/local&quot;)

if (APPLE)
   set(OPENSSL_ROOT &quot;/usr/local/opt/openssl&quot;)
elseif (UNIX)
   set(OPENSSL_ROOT &quot;/usr/include/openssl&quot;)
endif()
set(SECP256K1_ROOT &quot;/usr/local&quot;)

string(REPLACE &quot;;&quot; &quot;|&quot; TEST_PREFIX_PATH &quot;${CMAKE_PREFIX_PATH}&quot;)
string(REPLACE &quot;;&quot; &quot;|&quot; TEST_FRAMEWORK_PATH &quot;${CMAKE_FRAMEWORK_PATH}&quot;)
string(REPLACE &quot;;&quot; &quot;|&quot; TEST_MODULE_PATH &quot;${CMAKE_MODULE_PATH}&quot;)

set(BUILD_TESTS FALSE CACHE BOOL &quot;Build unit tests&quot;)

if(BUILD_TESTS)
   message(STATUS &quot;Building unit tests.&quot;)
   ExternalProject_Add(
     contracts_unit_tests
     LIST_SEPARATOR | # Use the alternate list separator
     CMAKE_ARGS -DCMAKE_BUILD_TYPE=${TEST_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${TEST_PREFIX_PATH} -DCMAKE_FRAMEWORK_PATH=${TEST_FRAMEWORK_PATH} -DCMAKE_MODULE_PATH=${TEST_MODULE_PATH} -DEOSIO_ROOT=${EOSIO_ROOT} -DLLVM_DIR=${LLVM_DIR} -DBOOST_ROOT=${BOOST_ROOT}
     SOURCE_DIR ${CMAKE_SOURCE_DIR}/tests
     BINARY_DIR ${CMAKE_BINARY_DIR}/tests
     BUILD_ALWAYS 1
     TEST_COMMAND   &quot;&quot;
     INSTALL_COMMAND &quot;&quot;
   )
else()
   message(STATUS &quot;Unit tests will not be built. To build unit tests, set BUILD_TESTS to true.&quot;)
endif()
