#!/usr/bin/env bash
set -eo pipefail

function usage() {
   printf &quot;Usage: $0 OPTION...
  -e DIR      Directory where EOSIO is installed. (Default: $HOME/eosio/X.Y)
  -c DIR      Directory where EOSIO.CDT is installed. (Default: /usr/local/eosio.cdt)
  -t          Build unit tests.
  -y          Noninteractive mode (Uses defaults for each prompt.)
  -h          Print this help menu.
   \\n&quot; &quot;$0&quot; 1&gt;&amp;2
   exit 1
}

BUILD_TESTS=false

if [ $# -ne 0 ]; then
  while getopts &quot;e:c:tyh&quot; opt; do
    case &quot;${opt}&quot; in
      e )
        EOSIO_DIR_PROMPT=$OPTARG
      ;;
      c )
        CDT_DIR_PROMPT=$OPTARG
      ;;
      t )
        BUILD_TESTS=true
      ;;
      y )
        NONINTERACTIVE=true
        PROCEED=true
      ;;
      h )
        usage
      ;;
      ? )
        echo &quot;Invalid Option!&quot; 1&gt;&amp;2
        usage
      ;;
      : )
        echo &quot;Invalid Option: -${OPTARG} requires an argument.&quot; 1&gt;&amp;2
        usage
      ;;
      * )
        usage
      ;;
    esac
  done
fi

# Source helper functions and variables.
. ./scripts/.environment
. ./scripts/helper.sh

if [[ ${BUILD_TESTS} == true ]]; then
   # Prompt user for location of eosio.
   eosio-directory-prompt
fi

# Prompt user for location of eosio.cdt.
cdt-directory-prompt

# Include CDT_INSTALL_DIR in CMAKE_FRAMEWORK_PATH
echo &quot;Using EOSIO.CDT installation at: $CDT_INSTALL_DIR&quot;
export CMAKE_FRAMEWORK_PATH=&quot;${CDT_INSTALL_DIR}:${CMAKE_FRAMEWORK_PATH}&quot;

if [[ ${BUILD_TESTS} == true ]]; then
   # Ensure eosio version is appropriate.
   nodeos-version-check

   # Include EOSIO_INSTALL_DIR in CMAKE_FRAMEWORK_PATH
   echo &quot;Using EOSIO installation at: $EOSIO_INSTALL_DIR&quot;
   export CMAKE_FRAMEWORK_PATH=&quot;${EOSIO_INSTALL_DIR}:${CMAKE_FRAMEWORK_PATH}&quot;
fi

printf &quot;\t=========== Building eosio.contracts ===========\n\n&quot;
RED=&#39;\033[0;31m&#39;
NC=&#39;\033[0m&#39;
CPU_CORES=$(getconf _NPROCESSORS_ONLN)
mkdir -p build
pushd build &amp;&gt; /dev/null
cmake -DBUILD_TESTS=${BUILD_TESTS} ../
make -j $CPU_CORES
popd &amp;&gt; /dev/null
