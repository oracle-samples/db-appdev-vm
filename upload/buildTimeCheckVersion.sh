#!/bin/bash

#
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 
# 

#################################################################################
#
# File: buildTimeCheckVersion.sh
#
# Description: diagnostic return database version to confirm patching if patching used
#
#################################################################################


echo marker 1690 $1
unset TWO_TASK
sqlplus sys/oracle as sysdba <<EOF
select 1690, action, namespace, version, id, comments from dba_registry_history;
exit;
EOF
