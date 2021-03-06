#!/usr/bin/env bash
# Copyright 2019 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VMS="management compute1 compute2 compute3 olt backoffice"
IPS="10.1.1.3 10.1.2.3 10.1.3.3 10.1.4.3 10.1.4.4 10.1.5.3"
GREEN='\033[1;32m'
RED='\033[1;31m'
RESET='\033[1;0m'

trap ctrl_c INT
function ctrl_c() {
    exit 1
}

GOOD=0
for C in $VMS; do
    echo -n "TEST: $C ... "
    FAILED=$(2>&1 vagrant ssh $C -- "bash -c 'O=""; for I in $IPS; do ping -c 1 -W 1 \$I >/dev/null 2>&1; if [ \$? -ne 0 ]; then O=\"\$I \$O\"; fi; done 2>&1; echo \$O'")
    if [ $? -ne 0 -o "$FAILED x" != " x" ]; then
        echo -e "${RED}FAILED${RESET} ($FAILED)"
        GOOD=1
    else
        echo -e "${GREEN}PASS${RESET}"
    fi
done

if [ $GOOD -eq 0 ]; then
    echo -e "${GREEN}PASS: Fabric functioning correctly${RESET}"
else
    >&2 echo -e "${RED}FAIL: Fabric not functioning correctly/completely${RESET}"
    exit 1
fi
