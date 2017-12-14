#! /bin/bash -x
# Various tests of LunarG Device Simulation (devsim) layer
# Uses 'jq' v1.5 https://stedolan.github.io/jq/

set -o nounset
set -o physical

cd $(dirname "${BASH_SOURCE[0]}")

if [ -t 1 ] ; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    NC=''
fi

ERRMSG=""
printf "$GREEN[ RUN      ]$NC $0\n"

if [ -z "${DISPLAY:-}" ] ; then
   printf "$RED[  FAILED  ]$NC environment variable DISPLAY requires a value\n"
   exit 1
fi
#[ -n "${DISPLAY:-}" ] || export DISPLAY=":0"

export LD_LIBRARY_PATH=${PWD}/../submodules/Vulkan-LoaderAndValidationLayers/loader:${LD_LIBRARY_PATH:-}
export VK_LAYER_PATH=${PWD}/../layersvt
export VK_INSTANCE_LAYERS="VK_LAYER_LUNARG_device_simulation"

export VK_DEVSIM_DEBUG_ENABLE="1"
#export VK_DEVSIM_EXIT_ON_ERROR="1"
#export VK_LOADER_DEBUG="all"

#############################################################################
# Test #1 Load config files, compare output of vkjson_info against a gold file.

VKJSON_INFO="${PWD}/../submodules/Vulkan-LoaderAndValidationLayers/libs/vkjson/vkjson_info"

FILENAME_01_IN="devsim_test1_in_ArrayOfVkFormatProperties.json:devsim_test1_in.json"
FILENAME_01_GOLD="devsim_test1_gold.json"
FILENAME_01_RESULT="device_simulation_layer_test_1.json"
FILENAME_01_STDOUT="device_simulation_layer_test_1.txt"
FILENAME_01_TEMP1="devsim_test1_temp1.txt"
FILENAME_01_TEMP2="devsim_test1_temp2.txt"

rm -f ${FILENAME_01_RESULT} ${FILENAME_01_STDOUT} ${FILENAME_01_TEMP1} ${FILENAME_01_TEMP2}

# Generate test output using known-good input
export VK_DEVSIM_FILENAME="${FILENAME_01_IN}"
${VKJSON_INFO} > ${FILENAME_01_STDOUT}
[ $? -eq 0 ] || ERRMSG="${VKJSON_INFO} failed"

# extract/sort/reformat files for predictable comparison
jq -S '{properties,features,memory,queues,formats}' ${FILENAME_01_GOLD} > ${FILENAME_01_TEMP1}
jq -S '{properties,features,memory,queues,formats}' ${FILENAME_01_RESULT} > ${FILENAME_01_TEMP2}

diff ${FILENAME_01_TEMP1} ${FILENAME_01_TEMP2} >> ${FILENAME_01_STDOUT}
[ $? -eq 0 ] || ERRMSG="diff file compare failed"

jq --slurp  --exit-status '.[0] == .[1]' ${FILENAME_01_TEMP1} ${FILENAME_01_TEMP2} >> ${FILENAME_01_STDOUT}
[ $? -eq 0 ] || ERRMSG="jq file compare failed"

#############################################################################
cat ${FILENAME_01_STDOUT}

if [ "$ERRMSG" ] ; then
   printf "$RED[  FAILED  ]$NC $ERRMSG\n"
   exit 1
fi

printf "$GREEN[  PASSED  ]$NC ${PGM}\n"
exit 0

# vim: set sw=4 ts=8 et ic ai:
